From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH net-next 8/8] bnx2x: Update version to 1.52.53-5
Date: Wed, 1 Sep 2010 22:30:16 +0300
Message-ID: <1283369416.5874.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1283370697.4403.139.camel@lb-tlvb-yanivr.il.broadcom.com>
 <1283359458.1797.190.camel@Joe-Laptop>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4477 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753888Ab0IATak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 15:30:40 -0400
In-Reply-To: <1283359458.1797.190.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-01 at 09:44 -0700, Joe Perches wrote:
> On Wed, 2010-09-01 at 22:51 +0300, Yaniv Rosner wrote:
> >  drivers/net/bnx2x/bnx2x.h |    4 ++--
> > +++ b/drivers/net/bnx2x/bnx2x.h
> > -#define DRV_MODULE_VERSION      "1.52.53-4"
> > -#define DRV_MODULE_RELDATE      "2010/16/08"
> > +#define DRV_MODULE_VERSION      "1.52.53-5"
> > +#define DRV_MODULE_RELDATE      "2010/01/09"
> >  #define BNX2X_BC_VER            0x040200
> 
> Your date scheme is very odd.
> 
> yyyy/dd/mm?
> 

You are right... It should have been yyyy/mm/dd. We are now working on
another patch series, and we will fix the format in that one.

Thanks for pointing it out,
Eilon


