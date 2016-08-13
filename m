From: Eric Leblond <eric@regit.org>
Subject: [PATCH net-next 0/2] libbpf: minor fix and API update
Date: Sat, 13 Aug 2016 14:17:21 +0200
Message-ID: <1471090643-22403-1-git-send-email-eric@regit.org>
Cc: Alexei Starovoitov <ast@fb.com>, wangnan0@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:43862 "EHLO home.regit.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752117AbcHMMjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2016 08:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

Here's a small patchset on libbpf fixing two issues I've encountered
when adding some eBPF related features to Suricata.

Patchset statistics:
 tools/lib/bpf/libbpf.c | 16 +++++++---------
 tools/lib/bpf/libbpf.h |  4 +++-
 2 files changed, 10 insertions(+), 10 deletions(-)

BR,
