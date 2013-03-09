From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH 1/3] driver: net: ethernet: cpsw: implement ethtool get/set phy setting
Date: Sat, 09 Mar 2013 11:49:24 +0100
Message-ID: <87ehfo4zm3.fsf@dell.be.48ers.dk>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
	<1362659421-11884-2-git-send-email-mugunthanvnm@ti.com>
	<8762135on4.fsf@dell.be.48ers.dk>
	<1362686350.2936.43.camel@bwh-desktop.uk.solarflarecom.com>
	<513991E6.5080400@ti.com>
	<1362754401.3248.8.camel@bwh-desktop.uk.solarflarecom.com>
	<5139FE94.6090004@ti.com> <20130309065106.GA2588@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	devicetree-discuss@lists.ozlabs.org, linux-omap@vger.kernel.org,
	b-cousson@ti.com, paul@pwsan.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:38198 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756767Ab3CIKta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 05:49:30 -0500
In-Reply-To: <20130309065106.GA2588@netboy.at.omicron.at> (Richard Cochran's
	message of "Sat, 9 Mar 2013 07:51:06 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Richard" == Richard Cochran <richardcochran@gmail.com> writes:

Hi,

 >> As Peter Korsgaard mentioned we need to have infrastructure to
 >> handle CPSW kind of hardware.

 Richard> This will be a big job, I think, but I agree that it is worth doing.

 Richard> I can think of one other switch-with-host-port device. Maybe
 Richard> we should start off by making a list of actual products and
 Richard> their capabilities, in order to get an overall idea of what we
 Richard> would need to develop.

Next to the dsa stuff with external switches, I can think of 3 other
devices off the top of my head:

Freescale imx287:
http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=i.MX287

Freescale T1022:
http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=T1020

Ralink RT3502:
http://www.netcheif.com/Reviews/VigorFly200/PDF/RT3052-product%20brief.pdf

-- 
Bye, Peter Korsgaard
