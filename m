From: David Miller <davem@davemloft.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
 `usbnet_set_settings':
Date: Wed, 07 Nov 2007 00:20:07 -0800 (PST)
Message-ID: <20071107.002007.00442348.davem@davemloft.net>
References: <200711012024.57412.toralf.foerster@gmx.de>
	<20071101141124.0cbe2897.randy.dunlap@oracle.com>
	<200711011632.18333.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, toralf.foerster@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	greg@kroah.com
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756345AbXKGIUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 03:20:15 -0500
In-Reply-To: <200711011632.18333.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David, I hate to say this and point you out like this, but you are a
real cancer for bug fixes to USB things in the kernel, and I'm very
tired of seeing things stuck in the mud (and engineering resources
wasted) because of how you handle things.  It's very bad for Linux,
and the USB code in particular.

If I had a nickel for every patch from someone else you grinded into
the ground and stalled I'd truly be a millionare.

You absolutely stifle development progress.  I thought my OHCI
deadlock patch was an isolated case (and nothing is still applied,
which is just awesome, my original patch was posted more than a month
ago), but you're doing the same exact thing to Adrian here too.

You want to see things fixed your way.  But you can get away with the
if, and only if, you can spend every day working on your own version
of fixes when you don't like the submitters version.  But unlike me
you don't have that luxury so you have to give patch submitters a
larger level of freedom and, plainly, just "let go".
