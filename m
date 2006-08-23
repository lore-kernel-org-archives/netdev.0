From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] Add Sonics Silicon Backplane driver
Date: Wed, 23 Aug 2006 13:04:28 +0200
Message-ID: <1156331069.3914.16.camel@ux156>
References: <200608231158.06178.mb@bu3sch.de>
	 <200608231159.59363.mb@bu3sch.de> <20060823105955.GB9627@unjust.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:21188 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964870AbWHWLEQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 07:04:16 -0400
To: Martin Michlmayr <tbm@cyrius.com>
In-Reply-To: <20060823105955.GB9627@unjust.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-23 at 11:59 +0100, Martin Michlmayr wrote:
> > +#define SSB_SPROM2_OPO			0x1078	/* OFDM Power Offset from CCK Level */
> > +#define  SSB_SPROM2_OPO_VALUE		0x00FF
> > +#define  SSB_SPROM2_OPO_UNUSED		0xFF00
> > +#define SSB_SPROM2_CCODE		0x107C	/* Two char Country Code */
> 
> This is badly formated.  Can you repost, please.

That's just because of the tabs, if the + in front is removed it's
formatted fine. And the indentation is supposed to be like that I'd
think.

johannes
