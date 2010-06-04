From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] [ath5k][leds] Ability to disable leds support. If leds
 support enabled do not force mac802.11 leds layer selection.
Date: Fri, 4 Jun 2010 10:09:19 -0400
Message-ID: <20100604140919.GA2492@tuxdriver.com>
References: <4c0804e2.0c3ddf0a.2771.10f7@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jirislaby@gmail.com>,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Lukas Turek <8an@praha12.net>,
	Mark Hindley <mark@hindley.org.uk>,
	Johannes Berg <johannes@sipsolutions.net>,
	Jiri Kosina <jkosina@suse.cz>, Kalle Valo <kalle.valo@iki.fi>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	Luca Verdesca <magooz@salug.it>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dmytro Milinevskyy <milinevskyy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43312 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921Ab0FDOPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 10:15:19 -0400
Content-Disposition: inline
In-Reply-To: <4c0804e2.0c3ddf0a.2771.10f7@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 03, 2010 at 10:39:30PM +0300, Dmytro Milinevskyy wrote:
> Hi!
> 
> Here is the patch to disable ath5k leds support on build stage.
> However if the leds support was enabled do not force selection of 802.11 leds layer.
> Depency on LEDS_CLASS is kept.
> 
> Suggestion given by Pavel Roskin and Bob Copeland applied.
> 
> Regards,
> 
> --Dima

Needs at least a Signed-off-by line, and preferrably a changelog that
explains what the patch is doing and (especially) why it is necessary.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
