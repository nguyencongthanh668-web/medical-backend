import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_device_tracking/cubit/notification/notification_cubit.dart';
import 'package:medical_device_tracking/cubit/notification/notification_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/widget/empty_widget/empty_widget.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().getNotification();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {

        if (state.status == NotificationStatus.success) {
          
          if (state.listNotification!.isEmpty) {
            return SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: context.base * 0.1,),

                  EmptyStateBanner(
                    title: 'KHÔNG CÓ THÔNG BÁO',
                    message: 'Hiện tại chưa có thông báo nào giành cho bạn',
                  ),
                ],
              )
            );
          }
          
          return SliverList.builder(
            itemCount: state.listNotification!.length,
            itemBuilder: (context, index) {
              return NotificationCard(
                title: state.listNotification![index].data.content,
                description: state.listNotification![index].data.content,
                level: 'Quan trọng',
                time: DateFormat('dd/MM/yyyy').format(DateTime.now()),
              );
            },
          );
        }

        return SliverToBoxAdapter();
      },
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String description;
  final String level;
  final String time;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.level,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = context.base;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: context.pxy(0.04, 0.015),
        padding: context.pMD,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: context.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: base * 0.03,
              offset: Offset(0, base * 0.01),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: base * 0.12,
              height: base * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF6),
                borderRadius: context.radiusMD,
              ),
              child: Center(
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: base * 0.05,
                  color: const Color(0xFF5B8DEF),
                ),
              ),
            ),

            SizedBox(width: base * 0.03),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: base * 0.045,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),

                  SizedBox(height: base * 0.01),

                  Text(
                    description,
                    style: TextStyle(
                      fontSize: base * 0.038,
                      color: Colors.grey[600],
                    ),
                  ),

                  SizedBox(height: base * 0.02),

                  Row(
                    children: [
                      Container(
                        padding: context.pxy(0.025, 0.008),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: context.radiusXL,
                        ),
                        child: Text(
                          "MỨC ĐỘ: $level",
                          style: TextStyle(
                            fontSize: base * 0.032,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),

                      SizedBox(width: base * 0.03),

                      Text(
                        time,
                        style: TextStyle(
                          fontSize: base * 0.034,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}