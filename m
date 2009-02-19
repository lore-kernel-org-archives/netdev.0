From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TG3: &&/|| confusion
Date: Wed, 18 Feb 2009 17:42:53 -0800 (PST)
Message-ID: <20090218.174253.154789292.davem@davemloft.net>
References: <49989494.6010804@gmail.com>
	<C27F8246C663564A84BB7AB343977242163420407C@IRVEXCHCCR01.corp.ad.broadcom.com>
	<20090217183439.GA7201@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33126
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753098AbZBSBnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:43:08 -0500
In-Reply-To: <20090217183439.GA7201@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 17 Feb 2009 10:34:39 -0800

> On Mon, Feb 16, 2009 at 09:27:19AM -0800, Michael Chan wrote:
> > Roel Kluin wrote:
> > 
> > > phyid Can't be both TG3_PHY_OUI_1 and TG3_PHY_OUI_2 and TG3_PHY_OUI_3.
> > >
> > > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
 ...
> Yes.  This is correct.
> 
> Acked-by: Matt Carlson <mcarlson@broadcom.com>

Applied.
