From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] samples/bpf: stress test bpf_get_stackid
Date: Tue, 08 Mar 2016 23:22:18 -0500 (EST)
Message-ID: <20160308.232218.393928649807336952.davem@davemloft.net>
References: <1457478474-1614041-1-git-send-email-ast@fb.com>
	<1457478474-1614041-2-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbcCIEWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 23:22:21 -0500
In-Reply-To: <1457478474-1614041-2-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 8 Mar 2016 15:07:53 -0800

> increase stress by also calling bpf_get_stackid() from
> various *spin* functions
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
