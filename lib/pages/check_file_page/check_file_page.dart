import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rf_example/core/app_colors.dart';
import 'package:rf_example/core/app_text_style.dart';
import 'package:rf_example/core/search_keyword_controller.dart';
import 'package:rf_example/data/services/scan_file_service.dart';
import 'package:rf_example/pages/check_file_page/dialog/file_viewer_dialog.dart';
import 'package:rf_example/pages/check_file_page/dialog/rename_file_dialog.dart';
import 'package:rf_example/providers/app_providers.dart';
import 'package:rf_example/widgets/feedback_toast.dart';
import 'package:rf_example/widgets/status_light.dart';

/// 查看檔案頁：列出 RFIDExport/ 的掃描結果，支援搜尋、改名、刪除與內容預覽
class CheckFilePage extends ConsumerStatefulWidget {
  const CheckFilePage({super.key});

  @override
  ConsumerState<CheckFilePage> createState() => _CheckFilePageState();
}

class _CheckFilePageState extends ConsumerState<CheckFilePage> {
  final _service = ScanFileService();
  final _search = SearchKeywordController();

  List<ScanFileSummary> _files = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final files = await _service.listValidScanFiles();
      if (!mounted) return;
      setState(() {
        _files = files;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _files = const [];
        _loading = false;
      });
      showErrorToast(context, message: '讀取檔案失敗：$e');
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListenableBuilder(
            listenable: _search,
            builder: (context, _) {
              final filtered = _files
                  .where((f) => _search.matchesAny([f.displayName]))
                  .toList();
              return Column(
                children: [
                  SizedBox(height: 14.h),
                  _buildSearchBar(),
                  SizedBox(height: 12.h),
                  _buildCountRow(filtered.length),
                  SizedBox(height: 12.h),
                  if (_loading)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 40.w,
                              height: 40.w,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Text(
                              '讀取檔案中...',
                              style: AppTextStyle.regular12.copyWith(
                                color: AppColors.textGreyIt,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_files.isEmpty)
                    Expanded(child: _buildEmptyState())
                  else
                    Expanded(child: _buildCardList(filtered)),
                  SizedBox(height: 8.h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      toolbarHeight: 50.h,
      backgroundColor: AppColors.black,
      elevation: 0,
      leadingWidth: 80.w,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 12.w),
            Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primary,
              size: 18.sp,
            ),
            SizedBox(width: 2.w),
            Text(
              '返回',
              style: AppTextStyle.backLabel.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
      title: Text(
        '查看檔案',
        style: AppTextStyle.appBarTitle.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
      actions: const [StatusLight()],
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  // ─── 搜尋框 ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.deepGrey,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textGreyIt, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: _search.textController,
              style: AppTextStyle.regular14.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: '搜尋檔案名稱',
                hintStyle: AppTextStyle.regular14.copyWith(
                  color: AppColors.textGreyIt,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_search.hasKeyword)
            GestureDetector(
              onTap: _search.clear,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.close_rounded, color: AppColors.midGrey, size: 18.w),
            ),
        ],
      ),
    );
  }

  // ─── 計數列 ───────────────────────────────────────────────────────────────

  Widget _buildCountRow(int count) {
    return Row(
      children: [
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.w),
          ),
          child: Text(
            '$count 筆檔案',
            style: AppTextStyle.regular12.copyWith(color: AppColors.primaryLight),
          ),
        ),
      ],
    );
  }

  // ─── 空狀態 ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.deepGrey,
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.06),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.folder_open_rounded,
              size: 38.w,
              color: AppColors.textGreyIt,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            '目前沒有檔案',
            style: AppTextStyle.medium18.copyWith(color: AppColors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            '先至掃描頁完成掃描並匯出',
            style: AppTextStyle.regular12.copyWith(color: AppColors.textGreyIt),
          ),
        ],
      ),
    );
  }

  // ─── 卡片清單 ─────────────────────────────────────────────────────────────

  Widget _buildCardList(List<ScanFileSummary> list) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          '找不到符合的檔案',
          style: AppTextStyle.regular14.copyWith(color: AppColors.textGreyIt),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 16.h),
      itemCount: list.length,
      separatorBuilder: (_, _) => SizedBox(height: 8.h),
      itemBuilder: (_, i) => _buildFileCard(list[i]),
    );
  }

  Widget _buildFileCard(ScanFileSummary file) {
    return GestureDetector(
      onTap: () => _onFileTap(file),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 14.h),
        decoration: BoxDecoration(
          color: AppColors.deepGrey,
          borderRadius: BorderRadius.circular(14.w),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── 左側 icon ──────────────────────────────────────────
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 24.w,
              ),
            ),
            SizedBox(width: 12.w),
            // ── 中間：名稱 + metadata ──────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.displayName,
                    style: AppTextStyle.medium16.copyWith(color: AppColors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.w,
                        color: AppColors.textGreyIt,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(file.exportTime),
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.textGreyIt,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 1,
                        height: 10.h,
                        color: AppColors.white.withValues(alpha: 0.15),
                      ),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.sensors_rounded,
                        size: 12.w,
                        color: AppColors.textGreyIt,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${file.deviceCount} 筆',
                        style: AppTextStyle.regular12.copyWith(
                          color: AppColors.textGreyIt,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── 右側：操作按鈕 ────────────────────────────────────
            Column(
              children: [
                GestureDetector(
                  onTap: () => _onEditTap(file),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.midGrey,
                      size: 18.w,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                GestureDetector(
                  onTap: () => _onDeleteTap(file),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.delete.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.delete,
                      size: 18.w,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }

  // ─── 行為 ─────────────────────────────────────────────────────────────────

  Future<void> _onDeleteTap(ScanFileSummary file) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppColors.deepGrey,
            title: Text('刪除檔案', style: AppTextStyle.medium16),
            content: Text(
              '確定要刪除「${file.displayName}」嗎？',
              style: AppTextStyle.regular14,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  '刪除',
                  style: TextStyle(color: AppColors.delete),
                ),
              ),
            ],
          ),
    );
    if (confirm != true) return;
    try {
      await _service.deleteScanFile(file.file);
      if (!mounted) return;
      showSuccessToast(context, message: '刪除成功');
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, message: '刪除失敗：$e');
    }
  }

  Future<void> _onEditTap(ScanFileSummary file) async {
    final newName = await showRenameFileDialog(
      context,
      currentName: file.displayName,
      validate: (name) => _service.validateRenameFilename(name, file.file),
    );
    if (newName == null) return;
    if (!mounted) return;

    try {
      await _service.renameScanFile(
        file: file.file,
        newDisplayName: newName,
      );
      if (!mounted) return;
      showSuccessToast(context, message: '儲存成功');
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, message: '改名失敗：$e');
    }
  }

  // 點整列開啟檔案預覽
  Future<void> _onFileTap(ScanFileSummary file) async {
    final repo = ref.read(deviceRepositoryProvider);
    List<FileDeviceEntry> entries;
    try {
      entries = await _service.readDevicesWithLookup(
        file: file.file,
        repository: repo,
      );
    } catch (e) {
      if (!mounted) return;
      showErrorToast(context, message: '讀取檔案失敗：$e');
      return;
    }
    if (!mounted) return;

    showFileViewerDialog(
      context,
      fileName: file.displayName,
      devices: entries,
      onEdit: () => _onEditTap(file),
      onDelete: () => _onDeleteTap(file),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '---';
    final local = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}/${two(local.month)}/${two(local.day)}';
  }
}
