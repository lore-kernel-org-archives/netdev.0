From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next 0/2] BPF update
Date: Tue, 12 Jan 2016 02:03:06 +0100
Message-ID: <cover.1452559602.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32858 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757960AbcALBDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 20:03:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two small BPF frontend updates.

The patchset is against your current net-next branch (pre master merge).

Thanks!

Daniel Borkmann (2):
  tc, bpf: check section names and type everywhere
  tc, bpf: more header checks on loading elf

 tc/tc_bpf.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 58 insertions(+), 6 deletions(-)

-- 
1.9.3
