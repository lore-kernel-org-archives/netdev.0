From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] Two minor BPF cleanups
Date: Wed, 23 Aug 2017 01:47:52 +0200
Message-ID: <cover.1503445395.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52258 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752622AbdHVXsG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 19:48:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor cleanups on devmap and redirect I still had
in my queue.

Thanks!

Daniel Borkmann (2):
  bpf: misc xdp redirect cleanups
  bpf: minor cleanups for dev_map

 kernel/bpf/devmap.c | 100 +++++++++++++++++++++-------------------------------
 net/core/filter.c   |  72 +++++++++++++++++--------------------
 2 files changed, 73 insertions(+), 99 deletions(-)

-- 
1.9.3
