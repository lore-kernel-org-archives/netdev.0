From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: cubic optimization
Date: Thu, 22 Mar 2007 12:11:39 -0700 (PDT)
Message-ID: <20070322.121139.85400399.davem@davemloft.net>
References: <20070321191537.GA28914@1wt.eu>
	<20070321131532.66e7f0e1@freekitty>
	<20070321131721.448de522@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35927
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965277AbXCVTLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:11:40 -0400
In-Reply-To: <20070321131721.448de522@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 21 Mar 2007 13:17:21 -0700

> Use willy's work in optimizing cube root by having table for small values.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Also applied to net-2.6.22, thanks Stephen.
