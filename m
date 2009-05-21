From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: set RTPROT_KERNEL to initial route
Date: Wed, 20 May 2009 17:39:21 -0700 (PDT)
Message-ID: <20090520.173921.232459716.davem@davemloft.net>
References: <4A12661F.1090301@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jean-mickael.guerin@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44390
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753900AbZEUAjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 20:39:23 -0400
In-Reply-To: <4A12661F.1090301@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Date: Tue, 19 May 2009 09:56:15 +0200

> The attached patch ensures RTPROT_KERNEL to the default initial route
> and fixes the problem for quagga.
> This is similar to "ipv6: protocol for address routes"
> f410a1fba7afa79d2992620e874a343fdba28332.

Applied, thanks!
