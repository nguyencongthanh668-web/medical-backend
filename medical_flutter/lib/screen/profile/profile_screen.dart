import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_device_tracking/cubit/profile/profile_cubit.dart';
import 'package:medical_device_tracking/cubit/profile/profile_state.dart';
import 'package:medical_device_tracking/extension/extension_on_buildcontext.dart';
import 'package:medical_device_tracking/screen/profile/log_out_button.dart';
import 'package:medical_device_tracking/screen/profile/profile_header.dart';
import 'package:medical_device_tracking/screen/profile/profile_info_widget.dart';
import 'package:medical_device_tracking/screen/profile/profile_screen_appbar.dart';
import 'package:medical_device_tracking/features/user_info_storage/user_info_storage.dart';
import 'package:medical_device_tracking/utils/user_role.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {

          if (state.status == ProfileStatus.success) {
            return CustomScrollView(
              slivers: [
                const ProfileScreenAppbar(),
                SliverToBoxAdapter(
                  child: ProfileHeader(
                    id: state.userInfo!.id.toString(),
                    name: state.userInfo!.displayName,
                    role: UserRole.label(state.userInfo!.role.isNotEmpty ? state.userInfo!.role : UserInfoStorage.getRole()),
                    imageUrl: state.userInfo!.profilePhotoUrl,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.base * 0.04),
                    child: Column(
                      children: [
                        InfoCard(
                          children: [
                            InfoRow(
                              label: "Họ và tên",
                              value: state.userInfo!.displayName,
                            ),
                            InfoRow(
                              label: "Mã nhân viên",
                              value: state.userInfo!.id.toString(),
                            ),
                            InfoRow(
                              label: "Chức vụ",
                              value: UserRole.label(state.userInfo!.role.isNotEmpty ? state.userInfo!.role : UserInfoStorage.getRole()),
                            ),
                            InfoRow(
                              label: "Giới tính",
                              value: state.userInfo!.gender?.toString() ?? '—',
                              isLast: true,
                            ),
                          ],
                        ),
                        InfoCard(
                          children: [
                            InfoRow(
                              label: "Số điện thoại",
                              value: state.userInfo!.phone,
                              highlight: true,
                            ),
                            InfoRow(
                              label: "Email",
                              value: state.userInfo!.email,
                              highlight: true,
                              isLast: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.base * 0.04,
                      vertical: context.base * 0.02,
                    ),
                    child: LogoutButton(),
                  ),
                ),
              ],
            );
          }

          return Container();
        },
      ),
    );
  }
}
