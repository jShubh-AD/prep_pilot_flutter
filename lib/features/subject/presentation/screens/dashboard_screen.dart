import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/chat/presentation/bloc/chat_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../widgets/subject_card.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../bloc/subject_bloc.dart';
import '../bloc/subject_event.dart';
import '../bloc/subject_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _triggerRefresh();
  }

  void _triggerRefresh() {
    context.read<SubjectBloc>().add(const FetchSubjectsEvent());
  }

  Future<void> _refreshSubjects() async {
    final bloc = context.read<SubjectBloc>();
    bloc.add(const FetchSubjectsEvent());
    // Wait until the loading state transitions to loaded or error
    await bloc.stream.firstWhere((state) => state is! SubjectLoading);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 768;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshSubjects,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Beautiful Header App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.bolt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'PrepPilot',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your AI Exam Prep Companion',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      IconButton.filledTonal(
                        onPressed: _triggerRefresh,
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reload Subjects',
                      ),
                    ],
                  ),
                ),
              ),

              // Title Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        'Select a Subject',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF14B8A6), // Green dot
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Subject List / Grid
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: BlocBuilder<SubjectBloc, SubjectState>(
                  builder: (context, state) {
                    if (state is SubjectInitial || state is SubjectLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 64.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    } else if (state is SubjectError) {
                      return SliverToBoxAdapter(
                        child: _buildErrorCard(state.message),
                      );
                    } else if (state is SubjectLoaded) {
                      final subjects = state.subject;
                      if (subjects.data == null || subjects.data!.isEmpty) {
                        return SliverToBoxAdapter(
                          child: _buildEmptyCard(),
                        );
                      }

                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isDesktop ? 300.0 : 200.0,
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 16.0,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final subject = subjects.data![index];
                            return SubjectCard(
                              subjects: subject,
                              index: index,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                      create: (context) => sl<ChatBloc>(),
                                      child: ChatScreen(subject: subject),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: subjects.data!.length,
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D).withOpacity(0.2), // Dark red
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF87171).withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFF87171),
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Connection Issue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Could not load subjects from PrepPilot server.\nMake sure the backend is running at ${ApiConstants.baseUrl}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _triggerRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.school_outlined,
            color: Color(0xFF6366F1),
            size: 54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Subjects Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t uploaded any textbooks or lecture notes to the system. Upload them using the admin dashboard or backend APIs to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _triggerRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Check for subjects'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
