import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_staff/all_staff_cubit.dart';
import 'package:medical_device_tracking/cubit/all_staff/all_staff_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';

class ListStaffWidget extends StatefulWidget {
  const ListStaffWidget({super.key});

  @override
  State<ListStaffWidget> createState() => _ListStaffWidgetState();
}

class _ListStaffWidgetState extends State<ListStaffWidget> {

  @override
  void initState() {
    super.initState();
    context.read<AllStaffCubit>().getListStaff();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllStaffCubit, AllStaffState>(
      builder: (context, state) {

        if (state.status == AllStaffStatus.success) {
          return SliverList.builder(
            itemCount: state.listUser!.length - 2,
            itemBuilder: (context, index) {
              return StaffCard(
                title: state.listUser![index].displayName,
                code: state.listUser![index].id.toString(),
                head: state.listUser![index].phone,
                imageUrl: state.listUser![index].profilePhotoUrl,
              );
            },
          );
        }

        return SliverToBoxAdapter();
      }
    );
  }
}

class StaffCard extends StatelessWidget {
  final String title;
  final String code;
  final String head;
  final String imageUrl;
  final bool isActive;
  final VoidCallback? onTap;

  const StaffCard({
    super.key,
    required this.title,
    required this.code,
    required this.head,
    required this.imageUrl,
    this.isActive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = context.base;

    return InkWell(
      onTap: onTap,
      borderRadius: context.radiusLG,
      child: Container(
        padding: context.pMD,
        margin: context.pMD,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: context.radiusLG,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: base * 0.04,
              offset: Offset(0, base * 0.02),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: base * 0.18,
              height: base * 0.18,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EDF3),
                borderRadius: context.radiusMD,
              ),
              child: (imageUrl.isNotEmpty) ? Image.network(imageUrl) : Icon(Icons.people)
            ),

            SizedBox(width: base * 0.04),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: base * 0.050,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      if (isActive)
                        Container(
                          padding: context.pxy(0.03, 0.01),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF3E3),
                            borderRadius: context.radiusXL,
                          ),
                          child: Text(
                            "Đang làm việc",
                            style: TextStyle(
                              fontSize: base * 0.035,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: base * 0.02),

                  Text(
                    "Mã: $code",
                    style: TextStyle(
                      fontSize: base * 0.045,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(height: base * 0.02),

                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: base * 0.045,
                        color: Colors.grey,
                      ),
                      SizedBox(width: base * 0.015),
                      Expanded(
                        child: Text(
                          overflow: TextOverflow.ellipsis,
                          "Liên hệ: $head",
                          style: TextStyle(
                            fontSize: base * 0.04,
                            color: Colors.black87,
                          ),
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
