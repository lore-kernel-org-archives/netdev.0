From: Matthew Fernandez <matthew.fernandez@gmail.com>
Subject: [PATCH net v2] bpf: fix trivial comment typo
Date: Thu, 5 Nov 2015 11:09:52 +1100
Message-ID: <563A9E50.9020105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, ast@kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf: fix trivial comment typo

Signed-off-by: Matthew Fernandez <matthew.fernandez@gmail.com>

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 334b1bd..0bd41f5 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -462,7 +462,7 @@ select_insn:

  		/* ARG1 at this point is guaranteed to point to CTX from
  		 * the verifier side due to the fact that the tail call is
-		 * handeled like a helper, that is, bpf_tail_call_proto,
+		 * handled like a helper, that is, bpf_tail_call_proto,
  		 * where arg1_type is ARG_PTR_TO_CTX.
  		 */
  		insn = prog->insnsi;
