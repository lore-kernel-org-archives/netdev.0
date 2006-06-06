From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] hush noisy ieee80211 CCMP printks
Date: Tue, 6 Jun 2006 11:02:20 -0400
Message-ID: <20060606150219.GD14823@knob.reflex>
References: <20060605001208.GA4585@opus.vpn-dev.reflex> <20060605133147.GA9567@jm.kir.nu> <20060605160335.GB25688@knob.reflex> <20060606034138.GB9568@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reflexsecurity.com ([72.54.64.74]:15269 "EHLO
	crown.reflexsecurity.com") by vger.kernel.org with ESMTP
	id S932200AbWFFPCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 11:02:24 -0400
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20060606034138.GB9568@jm.kir.nu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 08:41:38PM -0700, Jouni Malinen wrote:
> Do you happen to have a wireless sniffer that you could use to capture
> the frames? It would be interesting to see whether such a capture log
> could be mapped into the dropped frames shown in the kernel debug log.

I don't know. Would booting something like knoppix on another laptop
with some flavor of Intel wireless do? The only two laptops I have
regular access to are the bcm43xx one in question and another Intel one
that ordinarily runs winxp.

> Would you be interested in testing this with net/d80211 code and
> wireless-dev.git?

sure, I can do that. I'm fairly clumsy with git, so it may take a while.

Jason
