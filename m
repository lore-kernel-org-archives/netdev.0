From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sparc: bpf_jit: add SKF_AD_PKTTYPE support to
 JIT
Date: Fri, 19 Sep 2014 15:34:58 -0400 (EDT)
Message-ID: <20140919.153458.1586666418789079695.davem@davemloft.net>
References: <1410896135-9867-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58457 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757483AbaISTfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 15:35:00 -0400
In-Reply-To: <1410896135-9867-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 16 Sep 2014 12:35:35 -0700

> commit 233577a22089 ("net: filter: constify detection of pkt_type_offset")
> allows us to implement simple PKTTYPE support in sparc JIT
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks for doing this work Alexei.
