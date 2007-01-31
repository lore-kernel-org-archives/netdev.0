From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [linux-pm] [RFC] Runtime power management on	ipw2100
Date: Wed, 31 Jan 2007 14:11:20 +0000
Message-ID: <20070131141119.GA28903@srcf.ucam.org>
References: <20070131075249.GA22115@srcf.ucam.org> <p731wlbphz3.fsf@bingen.suse.de> <20070131102744.GA24424@srcf.ucam.org> <200701311148.20777.ak@suse.de> <1170244400.6746.31.camel@amit-laptop> <20070131130447.GF19643@elf.ucw.cz> <1170249876.6746.43.camel@amit-laptop> <20070131134416.GG19643@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Kucheria <amit.kucheria@nokia.com>,
	ext Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-pm@lists.osdl.org, ipw2100-devel@lists.sourceforge.net
To: Pavel Machek <pavel@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:55239 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933284AbXAaOLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 09:11:39 -0500
Content-Disposition: inline
In-Reply-To: <20070131134416.GG19643@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 02:44:16PM +0100, Pavel Machek wrote:

> Okay, but I'm somehow not sure if ipw2100 can do this kind of
> tricks. Yes, n800 is likely very nice toy :-).

Well, to an extent - if you use the wext power features, you can get it 
into a relatively low-power state at the cost of some performance. It's 
not as good as powering down the hardware completely, though.
-- 
Matthew Garrett | mjg59@srcf.ucam.org
