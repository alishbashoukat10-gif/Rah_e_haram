
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class MyCustomizationRequestsScreen extends StatefulWidget {
  const MyCustomizationRequestsScreen({super.key});

  @override
  State<MyCustomizationRequestsScreen> createState() =>
      _MyCustomizationRequestsScreenState();
}

class _MyCustomizationRequestsScreenState
    extends State<MyCustomizationRequestsScreen> {
  static const Color green = Color(0xFF063D34);
  static const Color gold = Color(0xFFC6A15B);

  List<dynamic> requests = [];
  bool isLoading = true;
  String? errorMessage;
  String? busyAction;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await ApiService.getMyCustomizationRequests();

      if (!mounted) return;

      setState(() {
        requests = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  String getText(dynamic value, [String fallback = 'Not available']) {
    if (value == null || value.toString().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  String formatPrice(dynamic value) {
    if (value == null) return 'Not available';

    final number = num.tryParse(value.toString());

    if (number == null) return value.toString();

    return 'Rs. ${number.toStringAsFixed(0)}';
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'available':
      case 'confirmed':
        return Colors.green;
      case 'rejected':
      case 'unavailable':
      case 'cancelled':
        return Colors.red;
      case 'responded':
        return Colors.blue;
      default:
        return gold;
    }
  }

  void showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : green,
      ),
    );
  }

  // ACCEPT AN AGENCY OFFER
  Future<void> acceptOffer(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    final requestId = getText(request['_id'], '');
    final responseId = getText(response['_id'], '');

    if (requestId.isEmpty || responseId.isEmpty) {
      showMessage(
        'Request or agency offer ID is missing.',
        isError: true,
      );
      return;
    }

    setState(() {
      busyAction = '$requestId:$responseId';
    });

    try {
      final result = await ApiService.acceptCustomizationOffer(
        requestId: requestId,
        responseId: responseId,
      );

      if (!mounted) return;

      showMessage(
        result['message'] ?? 'Agency offer accepted successfully.',
      );

      await loadRequests();
    } catch (e) {
      showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          busyAction = null;
        });
      }
    }
  }

  // REJECT AN AGENCY OFFER
  Future<void> rejectOffer(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
  ) async {
    final requestId = getText(request['_id'], '');
    final responseId = getText(response['_id'], '');

    if (requestId.isEmpty || responseId.isEmpty) {
      showMessage(
        'Request or agency offer ID is missing.',
        isError: true,
      );
      return;
    }

    final shouldReject = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Agency Offer?',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to reject this agency offer? '
            'You will not be able to accept this same offer afterwards.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep Offer'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Reject Offer'),
            ),
          ],
        );
      },
    );

    if (shouldReject != true || !mounted) return;

    setState(() {
      busyAction = '$requestId:$responseId';
    });

    try {
      final result = await ApiService.rejectCustomizationOffer(
        requestId: requestId,
        responseId: responseId,
      );

      if (!mounted) return;

      showMessage(
        result['message'] ?? 'Agency offer rejected successfully.',
      );

      await loadRequests();
    } catch (e) {
      showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          busyAction = null;
        });
      }
    }
  }

  // CREATE BOOKING USING THE ACCEPTED OFFER
  Future<void> proceedToBooking(
    Map<String, dynamic> request,
  ) async {
    final requestId = getText(request['_id'], '');

    if (requestId.isEmpty) {
      showMessage(
        'Customization request ID is missing.',
        isError: true,
      );
      return;
    }

    final shouldBook = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirm Customized Booking',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Do you want to proceed with booking this customized package '
            'at the accepted agency price?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );

    if (shouldBook != true || !mounted) return;

    setState(() {
      busyAction = requestId;
    });

    try {
      final result = await ApiService.createCustomizedBooking(
        customizationRequestId: requestId,
      );

      if (!mounted) return;

      final booking = result['booking'];

      final amount = booking is Map
          ? formatPrice(booking['totalAmount'])
          : 'Not available';

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            title: const Text(
              'Booking Created!',
              style: TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Your customized booking has been created successfully.\n\n'
              'Booking amount: $amount\n'
              'Booking status: Pending',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      await loadRequests();
    } catch (e) {
      showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          busyAction = null;
        });
      }
    }
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: green,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DISPLAY ONE AGENCY RESPONSE
  Widget buildAgencyResponse(
    Map<String, dynamic> request,
    Map<String, dynamic> response,
    String agencyName,
  ) {
    final availability = getText(
      response['availability'],
      'Pending',
    );

    final decision = getText(
      response['decision'],
      'Pending',
    );

    final responseAgency = response['agency'];

    String responseAgencyName = agencyName;

    if (responseAgency is Map) {
      responseAgencyName = getText(
        responseAgency['name'],
        agencyName,
      );
    }

    final requestStatus = getText(
      request['status'],
      'Pending',
    );

    final responseId = getText(response['_id'], '');
    final requestId = getText(request['_id'], '');

    final isAccepted = decision == 'Accepted' ||
        (requestStatus == 'Accepted' &&
            getText(request['selectedAgencyResponseId'], '') ==
                responseId);

    final isRejected = decision == 'Rejected';

    final isRequestOpen =
        requestStatus != 'Accepted' &&
        requestStatus != 'Rejected';

    final proposedPrice = num.tryParse(
      getText(response['proposedPrice'], ''),
    );

    final hasValidPrice =
        proposedPrice != null && proposedPrice > 0;

    final canAccept = isRequestOpen &&
        !isRejected &&
        decision == 'Pending' &&
        availability == 'Available' &&
        hasValidPrice;

    final canReject = canAccept;

    final actionKey = '$requestId:$responseId';
    final isThisActionLoading = busyAction == actionKey;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: gold.withOpacity(0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            responseAgencyName,
            style: const TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          infoRow('Availability', availability),

          infoRow(
            'Proposed price',
            formatPrice(response['proposedPrice']),
          ),

          if (getText(response['message'], '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Message: ${response['message']}',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],

          if (isAccepted) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You accepted this agency offer.',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isRejected) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    color: Colors.red,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You rejected this agency offer.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (canAccept && canReject) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: busyAction == null
                        ? () => acceptOffer(request, response)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isThisActionLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Accept'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton(
                    onPressed: busyAction == null
                        ? () => rejectOffer(request, response)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // DISPLAY ONE CUSTOMIZATION REQUEST
  Widget buildRequestCard(Map<String, dynamic> request) {
    final status = getText(
      request['status'],
      'Pending',
    );

    final agency = request['originalAgency'];

    String agencyName = 'Agency information unavailable';

    if (agency is Map) {
      agencyName = getText(agency['name']);
    }

    final responses = request['agencyResponses'] is List
        ? request['agencyResponses'] as List
        : [];

    final isAccepted = status == 'Accepted';

    final requestId = getText(request['_id'], '');

    final isBookingLoading = busyAction == requestId;

    final selectedResponseId = getText(
      request['selectedAgencyResponseId'],
      '',
    );

    final hasSelectedOffer = selectedResponseId.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: gold,
                size: 25,
              ),

              const SizedBox(width: 9),

              const Expanded(
                child: Text(
                  'Customization Request',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            getText(request['packageName'], 'Package'),
            style: const TextStyle(
              color: green,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${getText(request['packageType'])} Package',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),

          const Divider(height: 24),

          infoRow('Agency', agencyName),

          infoRow(
            'Original duration',
            '${getText(request['originalDuration'])} days',
          ),

          infoRow(
            'Requested duration',
            '${getText(request['requestedDuration'])} days',
          ),

          infoRow(
            'Original price',
            formatPrice(request['originalPrice']),
          ),

          infoRow(
            'Estimated price',
            formatPrice(request['estimatedPrice']),
          ),

          const SizedBox(height: 12),

          const Text(
            'Your Requirements',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F8F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              getText(request['specialRequirements']),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),

          if (responses.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),

            const Text(
              'Agency Response',
              style: TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 10),

            ...responses.map((response) {
              if (response is! Map) {
                return const SizedBox.shrink();
              }

              return buildAgencyResponse(
                request,
                Map<String, dynamic>.from(response),
                agencyName,
              );
            }),
          ] else ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Waiting for the agency to respond to your request.',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
          ],

          if (isAccepted && hasSelectedOffer) ...[
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: busyAction == null
                    ? () => proceedToBooking(request)
                    : null,
                icon: const Icon(
                  Icons.confirmation_num_outlined,
                ),
                label: isBookingLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Proceed to Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),

          const Text(
            'The estimated amount is not the final agency quotation. '
            'The agency must confirm availability and the final price.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),

      appBar: AppBar(
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Customization Requests',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: RefreshIndicator(
        color: green,
        onRefresh: loadRequests,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: green),
              )
            : errorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),

                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 45,
                      ),

                      const SizedBox(height: 12),

                      const Center(
                        child: Text(
                          'Unable to load requests',
                          style: TextStyle(
                            color: green,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      Center(
                        child: ElevatedButton(
                          onPressed: loadRequests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ),
                    ],
                  )
                : requests.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 130),

                          Icon(
                            Icons.inbox_outlined,
                            color: gold,
                            size: 55,
                          ),

                          SizedBox(height: 15),

                          Center(
                            child: Text(
                              'No Customization Requests Yet',
                              style: TextStyle(
                                color: green,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(height: 8),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              'Your submitted package customization '
                              'requests will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            'Track your requests',
                            style: TextStyle(
                              color: green,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '${requests.length} request(s) submitted',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 18),

                          ...requests.map((item) {
                            if (item is! Map) {
                              return const SizedBox.shrink();
                            }

                            return buildRequestCard(
                              Map<String, dynamic>.from(item),
                            );
                          }),
                        ],
                      ),
      ),
    );
  }
}
