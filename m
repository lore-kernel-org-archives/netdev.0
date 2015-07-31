From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf_jit_disasm: also support reading jit dump
 from file
Date: Fri, 31 Jul 2015 15:13:45 -0700 (PDT)
Message-ID: <20150731.151345.1585070995879177623.davem@davemloft.net>
References: <63f20d2290807aa457cb18da45eb8fc7ff751132.1438264568.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbbGaWNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:13:49 -0400
In-Reply-To: <63f20d2290807aa457cb18da45eb8fc7ff751132.1438264568.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 30 Jul 2015 16:04:22 +0200

> This patch adds support to read the dmesg BPF JIT dump also from a
> file instead of the klog buffer. I found this quite useful when going
> through some 'before/after patch' logs. It also fixes a regex leak
> found by valgrind when no image dump was found.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
