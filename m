From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] Minor cls_bpf updates
Date: Wed, 23 Sep 2015 21:56:45 +0200
Message-ID: <cover.1443037353.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36047 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653AbbIWT44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 15:56:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor updates resp. follow-ups on cls_bpf, please see
individual patches for details. Will follow with the iproute2
patch after this series.

Thanks!

Daniel Borkmann (3):
  cls_bpf: also dump TCA_BPF_FLAGS
  cls_bpf: make binding to classid optional
  cls_bpf: limit allowed exec opcodes subset

 net/sched/cls_bpf.c | 31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

-- 
1.9.3
