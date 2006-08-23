From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 1/2] Add Sonics Silicon Backplane driver
Date: Wed, 23 Aug 2006 11:59:55 +0100
Message-ID: <20060823105955.GB9627@unjust.cyrius.com>
References: <200608231158.06178.mb@bu3sch.de> <200608231159.59363.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:6673 "EHLO sorrow.cyrius.com")
	by vger.kernel.org with ESMTP id S964880AbWHWK75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 06:59:57 -0400
To: Michael Buesch <mb@bu3sch.de>
Content-Disposition: inline
In-Reply-To: <200608231159.59363.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Michael Buesch <mb@bu3sch.de> [2006-08-23 11:59]:
> +#define SSB_SPROM1_OEM			0x1076	/* 8 bytes OEM string (rev 1 only) */
> +/* SPROM Revision 2 (inherits from rev 1) */
> +#define SSB_SPROM2_BFLHI		0x1038	/* Boardflags (high 16 bits) */
> +#define SSB_SPROM2_MAXP_A		0x103A	/* A-PHY Max Power */
> +#define  SSB_SPROM2_MAXP_A_HI		0x00FF	/* Max Power High */
> +#define  SSB_SPROM2_MAXP_A_LO		0x1100	/* Max Power Low */
> +#define  SSB_SPROM2_MAXP_A_LO_SHIFT	8
> +#define SSB_SPROM2_PA1LOB0		0x103C	/* A-PHY PowerAmplifier Low Settings */
> +#define SSB_SPROM2_PA1LOB1		0x103E	/* A-PHY PowerAmplifier Low Settings */
> +#define SSB_SPROM2_PA1LOB2		0x1040	/* A-PHY PowerAmplifier Low Settings */
> +#define SSB_SPROM2_PA1HIB0		0x1042	/* A-PHY PowerAmplifier High Settings */
> +#define SSB_SPROM2_PA1HIB1		0x1044	/* A-PHY PowerAmplifier High Settings */
> +#define SSB_SPROM2_PA1HIB2		0x1046	/* A-PHY PowerAmplifier High Settings */
> +#define SSB_SPROM2_OPO			0x1078	/* OFDM Power Offset from CCK Level */
> +#define  SSB_SPROM2_OPO_VALUE		0x00FF
> +#define  SSB_SPROM2_OPO_UNUSED		0xFF00
> +#define SSB_SPROM2_CCODE		0x107C	/* Two char Country Code */

This is badly formated.  Can you repost, please.
-- 
Martin Michlmayr
tbm@cyrius.com
