import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/messageModel_.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onRead;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onRead,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _hasMarkedRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mark message as read when visible (only for messages from others)
    if (!widget.isMe &&
        widget.onRead != null &&
        widget.message.readAt == null &&
        !_hasMarkedRead) {
      _hasMarkedRead = true;
      // Delay to ensure widget is fully rendered
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          widget.onRead!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundImage: widget.message.sender.avatarUrl != null
                  ? NetworkImage(widget.message.sender.avatarUrl!)
                  : null,
              child: widget.message.sender.avatarUrl == null
                  ? Text(widget.message.sender.username[0].toUpperCase())
                  : null,
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: widget.isMe ? Colors.teal : Colors.grey[200],
                borderRadius: BorderRadius.circular(16.r).copyWith(
                  bottomLeft: widget.isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                  bottomRight: widget.isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isMe)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(
                        widget.message.sender.username,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                  Text(
                    widget.message.content,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: widget.isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: widget.isMe ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      if (widget.isMe) ...[
                        SizedBox(width: 4.w),
                        _buildStatusIcon(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (widget.isMe) SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    // Debug print to check status
    print('📊 Message status - ID: ${widget.message.id}');
    print('   readAt: ${widget.message.readAt}');
    print('   deliveredAt: ${widget.message.deliveredAt}');

    // Message is READ (blue double checkmark) - HIGHEST PRIORITY
    if (widget.message.readAt != null) {
      print('   Showing BLUE double checkmark (read)');
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.done_all,
            size: 12.sp,
            color: Colors.blue,
          ),
          // Add a small checkmark to indicate both ticks
          Icon(
            Icons.done_all,
            size: 12.sp,
            color: Colors.blue,
          ),
        ],
      );
    }
    // Message is DELIVERED (grey double checkmark)
    else if (widget.message.deliveredAt != null) {
      print('   Showing GREY double checkmark (delivered)');
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.done_all,
            size: 12.sp,
            color: Colors.white70,
          ),
        ],
      );
    }
    // Message is SENT (single checkmark)
    else {
      print('   Showing single checkmark (sent)');
      return Icon(
        Icons.done,
        size: 12.sp,
        color: Colors.white70,
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    // If message is from today, show time with AM/PM
    if (time.day == now.day &&
        time.month == now.month &&
        time.year == now.year) {
      return _formatTimeOfDay(time);
    }
    // If message is from yesterday
    else if (time.day == now.day - 1 &&
        time.month == now.month &&
        time.year == now.year) {
      return 'Yesterday ${_formatTimeOfDay(time)}';
    }
    // Show date
    else {
      return '${time.day}/${time.month} ${_formatTimeOfDay(time)}';
    }
  }

  String _formatTimeOfDay(DateTime time) {
    int hour = time.hour;
    int minute = time.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  void dispose() {
    super.dispose();
  }
}