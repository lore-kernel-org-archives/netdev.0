From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v1] samples/bpf: Add a .gitignore for binaries
Date: Sun, 12 Feb 2017 22:23:56 +0100
Message-ID: <20170212212356.11675-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:58912 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdBLVY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 16:24:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
---
 samples/bpf/.gitignore | 32 ++++++++++++++++++++++++++++++++
 1 file changed, 32 insertions(+)
 create mode 100644 samples/bpf/.gitignore

diff --git a/samples/bpf/.gitignore b/samples/bpf/.gitignore
new file mode 100644
index 000000000000..a7562a5ef4c2
--- /dev/null
+++ b/samples/bpf/.gitignore
@@ -0,0 +1,32 @@
+fds_example
+lathist
+lwt_len_hist
+map_perf_test
+offwaketime
+sampleip
+sockex1
+sockex2
+sockex3
+sock_example
+spintest
+tc_l2_redirect
+test_cgrp2_array_pin
+test_cgrp2_attach
+test_cgrp2_attach2
+test_cgrp2_sock
+test_cgrp2_sock2
+test_current_task_under_cgroup
+test_lru_dist
+test_overhead
+test_probe_write_user
+trace_event
+trace_output
+tracex1
+tracex2
+tracex3
+tracex4
+tracex5
+tracex6
+xdp1
+xdp2
+xdp_tx_iptunnel
-- 
2.11.0
