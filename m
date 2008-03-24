From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/03] ISATAP V2 (header file changes)
Date: Mon, 24 Mar 2008 14:37:43 +0900 (JST)
Message-ID: <20080324.143743.113268628.yoshfuji@linux-ipv6.org>
References: <20071129102940.GC22537@gondor.apana.org.au>
	<20071129.195459.55971471.yoshfuji@linux-ipv6.org>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Fred.L.Templin@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:54929 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751964AbYCXFgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:36:18 -0400
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com> (at Tue, 15 Jan 2008 11:57:04 -0800), "Templin, Fred L" <Fred.L.Templin@boeing.com> says:

> This patch updates the Linux the Intra-Site Automatic Tunnel Addressing
> Protocol (ISATAP) implementation. It places the ISATAP potential router
> list (PRL) in the kernel and adds three new private ioctls for PRL
> management. The diffs are specific to the netdev net-2.6.25 development
> tree taken by "git pull" on 1/14/08.
> 
> Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

I applied this into my queue for 2.6.26 (with some modification).
Thanks.

--yoshfuji
