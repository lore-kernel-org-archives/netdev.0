From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: add/use RMCR.RNC bit
Date: Wed, 23 Oct 2013 16:50:34 -0400 (EDT)
Message-ID: <20131023.165034.537485764263918532.davem@davemloft.net>
References: <201310160229.58735.sergei.shtylyov@cogentembedded.com>
	<5266F94E.9030406@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, horms@verge.net.au
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab3JWUug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 16:50:36 -0400
In-Reply-To: <5266F94E.9030406@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 23 Oct 2013 02:16:46 +0400

> Hello.
> 
> On 10/16/2013 02:29 AM, Sergei Shtylyov wrote:
> 
>> Declare 'enum EMCR_BIT' containing the single member for the RMCR.RNC
>> bit and
> 
>    Hm, looks like I typoed here, should have been RMCR_BIT. David, should
>    I resubmit or you can fix it while applying? Or simply not worth the
>    trouble?

Applied, with the typo fixed, thanks.
