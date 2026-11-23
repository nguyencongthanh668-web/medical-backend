import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/all_department/all_department_cubit.dart';
import 'package:medical_device_tracking/cubit/all_department/all_department_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/utils/app_colors.dart';

class ListDepartmentWidget extends StatefulWidget {
  const ListDepartmentWidget({super.key});

  @override
  State<ListDepartmentWidget> createState() => _ListDepartmentWidgetState();
}

class _ListDepartmentWidgetState extends State<ListDepartmentWidget> {

  @override
  void initState() {
    super.initState();
    context.read<AllDepartmentCubit>().getAllDepartment();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AllDepartmentCubit, AllDepartmentState>(
      builder: (context, state) {

        if (state.status == AllDepartmentStatus.success) {
          return SliverList.builder(
            itemCount: state.listDepartment!.length,
            itemBuilder: (context, index) {
              return DepartmentCard(
                title: state.listDepartment![index].title,
                code: state.listDepartment![index].code,
                head: state.listDepartment![index].phone,
              );
            },
          );
        }

        return SliverToBoxAdapter();

      },
    );
  }
}

class DepartmentCard extends StatelessWidget {
  final String title;
  final String code;
  final String head;
  final bool isActive;
  final VoidCallback? onTap;

  const DepartmentCard({
    super.key,
    required this.title,
    required this.code,
    required this.head,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    vertical: context.base * 0.02,
                    horizontal: context.base * 0.02,
                  ),
                  child: Icon(
                    Icons.apartment,
                    size: context.base * 0.15,
                    color: AppColors.mainColor,
                  )
              ),
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
                            "Hoạt động",
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