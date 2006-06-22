From: Andreas Mohr <andi@rhlx01.fht-esslingen.de>
Subject: Re: [-mm patch] drivers/net/ni5010.c: fix compile error
Date: Thu, 22 Jun 2006 10:13:16 +0200
Message-ID: <20060622081316.GA24980@rhlx01.fht-esslingen.de>
References: <20060621034857.35cfe36f.akpm@osdl.org> <20060621151057.GF9111@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.fht-esslingen.de ([129.143.116.10]:40361 "EHLO
	rhlx01.fht-esslingen.de") by vger.kernel.org with ESMTP
	id S932840AbWFVINR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:13:17 -0400
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20060621151057.GF9111@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jun 21, 2006 at 05:10:57PM +0200, Adrian Bunk wrote:
> On Wed, Jun 21, 2006 at 03:48:57AM -0700, Andrew Morton wrote:
> >...
> > Changes since 2.6.17-rc6-mm2:
> >...
> > +ni5010-netcard-cleanup.patch
> > 
> >  netdev cleanup
> >...
> 
> This patch fixes the following compile error with CONFIG_NI5010=y:

Doh, thanks!
(that should teach me to do non-module runs, too)

Andreas Mohr
