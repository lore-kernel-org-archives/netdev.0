From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -master 0/2] Two misc BPF updates
Date: Sat, 13 May 2017 02:32:33 +0200
Message-ID: <cover.1494635217.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42827 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756625AbdEMAcr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 20:32:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Requires header rebase with -net.

Thanks!

Daniel Borkmann (2):
  bpf: update printing of generic xdp mode
  bpf: dump error to the user when retrieving pinned prog fails

 ip/iplink_xdp.c | 19 +++++++++++--------
 lib/bpf.c       | 12 +++++++++++-
 2 files changed, 22 insertions(+), 9 deletions(-)

-- 
1.9.3
