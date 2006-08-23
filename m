From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 1/2] Add Sonics Silicon Backplane driver
Date: Wed, 23 Aug 2006 13:26:51 +0200
Message-ID: <20060823112651.GW5319@deprecation.cyrius.com>
References: <200608231158.06178.mb@bu3sch.de> <200608231159.59363.mb@bu3sch.de> <20060823105955.GB9627@unjust.cyrius.com> <1156331069.3914.16.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:22801 "EHLO
	sorrow.cyrius.com") by vger.kernel.org with ESMTP id S932394AbWHWL1D
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 07:27:03 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156331069.3914.16.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> [2006-08-23 13:04]:
> > > +#define  SSB_SPROM2_OPO_VALUE		0x00FF
> > > +#define  SSB_SPROM2_OPO_UNUSED		0xFF00
> > > +#define SSB_SPROM2_CCODE		0x107C	/* Two char Country Code */
> > 
> > This is badly formated.  Can you repost, please.
> 
> That's just because of the tabs, if the + in front is removed it's
> formatted fine. And the indentation is supposed to be like that I'd
> think.

Yes, sorry, I didn't realize that registers and register values have
different indentation.
-- 
Martin Michlmayr
http://www.cyrius.com/
