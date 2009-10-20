From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH] Add new cs89x0 driver
Date: Tue, 20 Oct 2009 10:55:01 +0100
Message-ID: <20091020095501.GA306@fluff.org.uk>
References: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Lennert Buytenhek <kernel@wantstofly.org>,
	Ivo Clarysse <ivo.clarysse@gmail.com>,
	Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:44516 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750776AbZJTJzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 05:55:19 -0400
Content-Disposition: inline
In-Reply-To: <1240387172-21818-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 09:59:30AM +0200, Sascha Hauer wrote:
> While this is a very old chip it is still in use on some embedded boards.
> I see myself unable to fix the in Kernel driver to bring it to driver
> model support, so this patch adds a new driver designed to replace
> the old one, at least for non-ISA hardware.

I think it is worthwile, there's a number of SMDK boards and similar
which have used this board, including boards released in the last year
or so.

I will try and see if I can do some reviewing and testing of this in
the next few days.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
