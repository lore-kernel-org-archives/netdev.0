From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] [Rev2] MPC5121 FEC support
Date: Wed, 18 Jun 2008 10:43:39 -0500
Message-ID: <20080618154338.GA3887@loki.buserror.net>
References: <1213729717-26688-1-git-send-email-jrigby@freescale.com> <48581188.90102@freescale.com> <20080617195739.GB13147@uranus.ravnborg.org> <485818AA.8090701@freescale.com> <20080617210055.GA13468@uranus.ravnborg.org> <485828B0.4010101@freescale.com> <Pine.LNX.4.64.0806171648300.7584@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>, John Rigby <jrigby@freescale.com>,
	linuxppc-dev@ozlabs.org, jeff@garzik.org, netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35240 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbYFRPoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 11:44:06 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806171648300.7584@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 04:52:25PM -0700, Trent Piepho wrote:
> Why is FS_ENET_HAS_SCC a bool, and not tristate?

That was an oversight on my part -- they should be tristate.

-Scott
