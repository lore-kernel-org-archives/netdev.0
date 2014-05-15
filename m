From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/2] tools: bpf_jit_disasm: trivial fixes
Date: Thu, 15 May 2014 15:56:37 -0700
Message-ID: <1400194599-5247-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:58619 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaEOW4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 18:56:52 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so1660295pab.17
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 15:56:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two trivial fixes for very useful bpf_jit_disasm tool

Alexei Starovoitov (2):
  tools: bpf_jit_disasm: ignore image address for disasm
  tools: bpf_jit_disasm: increase image buffer size

 tools/net/bpf_jit_disasm.c |   20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

-- 
1.7.9.5
