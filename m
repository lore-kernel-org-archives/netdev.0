From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] hush noisy ieee80211 CCMP printks
Date: Mon, 5 Jun 2006 15:22:27 -0400
Message-ID: <20060605192222.GK6068@tuxdriver.com>
References: <20060605001208.GA4585@opus.vpn-dev.reflex> <20060605133147.GA9567@jm.kir.nu> <20060605160335.GB25688@knob.reflex>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:62217 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751311AbWFETWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 15:22:37 -0400
To: Jason Lunz <lunz@falooley.org>
Content-Disposition: inline
In-Reply-To: <20060605160335.GB25688@knob.reflex>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 05, 2006 at 12:03:35PM -0400, Jason Lunz wrote:

> If the messages are actually useful, and unusual, then they should
> probably stay. But I get a LOT of them, and my wireless is working just
> fine.

I'm dropping this patch, based on Jouni's comments.  If you want to
reformulate a patch that make this output controlled by some sort of
debug option (runtime or compile-time), then please do so and post
it for consideration.

Thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
