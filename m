From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.19-rc6-mm1: no help text for TCP_MD5SIG_DEBUG
Date: Thu, 23 Nov 2006 17:37:15 -0800 (PST)
Message-ID: <20061123.173715.64809898.davem@davemloft.net>
References: <20061123021703.8550e37e.akpm@osdl.org>
	<20061123233030.GN3557@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39642
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1757551AbWKXBhI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 20:37:08 -0500
To: bunk@stusta.de
In-Reply-To: <20061123233030.GN3557@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 24 Nov 2006 00:30:30 +0100

> On Thu, Nov 23, 2006 at 02:17:03AM -0800, Andrew Morton wrote:
> >...
> > Changes since 2.6.19-rc5-mm2:
> >...
> >  git-net.patch
> >...
> >  git trees
> >...
> 
> TCP_MD5SIG_DEBUG lacks a help text.

Thanks for the report Adrian, I'll take care of this.
