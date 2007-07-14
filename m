From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET_CLS_RSVP6 should depend on IPV6
Date: Sat, 14 Jul 2007 13:04:35 -0700 (PDT)
Message-ID: <20070714.130435.126576296.davem@davemloft.net>
References: <4698A7B6.1030302@googlemail.com>
	<4698ED6E.6020502@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nix.or.die@googlemail.com, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40983
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760924AbXGNUEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 16:04:33 -0400
In-Reply-To: <4698ED6E.6020502@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sat, 14 Jul 2007 17:36:14 +0200

> Gabriel C wrote:
> > cls_rsvp6 only works with IPV6 enabled kernels and IMO it should depends
> > on IPV6.
> 
> 
> I can't see any functional dependency on IPv6, what exactly are you
> refering to? People might want to use it on a bridge for example
> without having IPv6 running locally.

That's my feeling as well.
