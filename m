From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH net-next 2/3] can: mscan-mpc5xxx: add support for the MPC521x processor
Date: Mon, 04 Jan 2010 20:40:27 +0100
Message-ID: <20100104194027.CB2053F6FD@gemini.denx.de>
References: <1262420274-16586-1-git-send-email-wg@grandegger.com> <1262420274-16586-2-git-send-email-wg@grandegger.com> <1262420274-16586-3-git-send-email-wg@grandegger.com> <20100102135734.GC2239@pengutronix.de> <4B3F6F6B.5070004@grandegger.com> <20100104162441.GA4665@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Socketcan-core@lists.berlios.de, Netdev@vger.kernel.org,
	Devicetree-discuss@lists.ozlabs.org, Linuxppc-dev@lists.ozlabs.org,
	Wolfgang Grandegger <wg@denx.de>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
In-reply-to: <20100104162441.GA4665@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Wolfram,

in message <20100104162441.GA4665@pengutronix.de> you wrote:
> 
> One further note: I couldn't spot any code handling Rev1 of the MPC5121? Do you
> plan to add such code? If not, we should at least put a comment that it is
> missing. The binding documentation should be updated as well, as you can't use
> all options on such revisions.

We only support MPC512x Rev. 2 (and later). This is also true for
other parts of the mainline kernel code - see for example trhe NAND
driver.


Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
Include the success of others in your dreams for your own success.
