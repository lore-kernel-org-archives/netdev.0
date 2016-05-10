From: David Miller <davem@davemloft.net>
Subject: Re: networking/ip-sysctl.txt: SRR or SSRR
Date: Tue, 10 May 2016 14:13:56 -0400 (EDT)
Message-ID: <20160510.141356.408283356817506794.davem@davemloft.net>
References: <alpine.DEB.2.20.12.1605081823420.3193@trent.utfs.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lists@nerdbynature.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbcEJSN6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 14:13:58 -0400
In-Reply-To: <alpine.DEB.2.20.12.1605081823420.3193@trent.utfs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Kujau <lists@nerdbynature.de>
Date: Sun, 8 May 2016 18:23:59 -0700 (PDT)

> In Documentation/networking/ip-sysctl.txt, the accept_source_route 
> parameter is described with:
> 
>   Accept packets with SRR option.

Every single variable name and function name dealing with this IP
option uses "srr", therefore I don't think we should adjust the
documentation either.

"srr" covers both the loose source route option and the strict source
route option.

Thanks.
