From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next][V2] net: filter: fix the comments
Date: Fri, 10 Oct 2014 15:12:14 -0400 (EDT)
Message-ID: <20141010.151214.863365491786262186.davem@davemloft.net>
References: <1412920611-2094-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com,
	alexei.starovoitov@gmail.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbaJJTMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:12:17 -0400
In-Reply-To: <1412920611-2094-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 10 Oct 2014 13:56:51 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. sk_run_filter has been renamed, sk_filter() is using SK_RUN_FILTER.
> 2. Remove wrong comments about storing intermediate value.
> 3. replace sk_run_filter with __bpf_prog_run for check_load_and_stores's
> comments
> 
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
