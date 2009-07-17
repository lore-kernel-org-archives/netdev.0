From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 2/2 v2] MPC52xx FEC: be more conservative when setting MII_SPEED register
Date: Fri, 17 Jul 2009 14:35:19 +0200
Message-ID: <20090717123519.C7E1D832E416@gemini.denx.de>
References: <1247671133-12148-1-git-send-email-wd@denx.de> <1247780546-4426-2-git-send-email-wd@denx.de> <20090717094725.GC3150@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:35920 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934499AbZGQMfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 08:35:23 -0400
In-reply-to: <20090717094725.GC3150@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Wolfram Sang,

In message <20090717094725.GC3150@pengutronix.de> you wrote:
> 
> In the probe-function when mdio_speed is set, there is still the old formula
> used. Wouldn't that be better in sync?

Good point. Next version of patch following soon.

Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Prof:        So the American government went to IBM to come up with a
             data encryption standard and they came up with ...
Student:     EBCDIC!
