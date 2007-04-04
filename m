From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: [-mm patch] make drivers/net/qla3xxx.c:PHY_DEVICES[] static
Date: Wed, 4 Apr 2007 10:11:12 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07A253EB@AVEXCH1.qlogic.org>
References: <46130EA4.4000403@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Adrian Bunk" <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47190 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbXDDRL3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 13:11:29 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46130EA4.4000403@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian,

Sorry about the upper case stuff.  The new PHY code was ported from our
firmware guys and the case didn't not get changed.  I normally will make
such changes but it didn't get done this time.  I will clean it up in
the near future.

Ron 

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com] 
> Sent: Tuesday, April 03, 2007 7:34 PM
> To: Adrian Bunk
> Cc: Andrew Morton; Linux Driver; 
> linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [-mm patch] make 
> drivers/net/qla3xxx.c:PHY_DEVICES[] static
> 
> Adrian Bunk wrote:
> > On Fri, Mar 30, 2007 at 01:05:59AM -0700, Andrew Morton wrote:
> >> ...
> >> Changes since 2.6.21-rc5-mm2:
> >> ...
> >>  git-netdev-all.patch
> >> ...
> >>  git trees
> >> ...
> > 
> > 
> > This patch makes the needlessly global PHY_DEVICES[] static.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > 
> > ---
> > 
> > BTW: Why is the name uppercase?
> 
> applied
> 
> 
> 
