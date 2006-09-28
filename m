From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 16:32:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609281632200.28620@d.namei>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net> <1159474625.3741.6.camel@rh4>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:32986 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750748AbWI1Uck (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 16:32:40 -0400
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1159474625.3741.6.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006, Michael Chan wrote:

> I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
> Dumping 64K worth of registers and blinking the LEDs should be
> restricted.

Out of curiosity -- why?



-- 
James Morris
<jmorris@namei.org>
