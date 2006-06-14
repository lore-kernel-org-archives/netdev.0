From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Remove Prism II support from Orinoco
Date: Wed, 14 Jun 2006 13:53:22 +0200
Message-ID: <20060614135322.4bbb8d1b@griffin.suse.cz>
References: <20060610175010.GA4617@divinity>
	<20060610180850.GP7420@redhat.com>
	<20060611222719.GA13139@redhat.com>
	<20060611224054.GB13139@redhat.com>
	<20060611224954.GA2880@divinity>
	<20060612152434.GA14851@tuxdriver.com>
	<4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com>
	<20060613042048.GA14824@shell0.pdx.osdl.net>
	<448E3F80.5050103@cube.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46761 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751253AbWFNLxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 07:53:24 -0400
To: Faidon Liambotis <faidon@cube.gr>
In-Reply-To: <448E3F80.5050103@cube.gr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Jun 2006 07:30:56 +0300, Faidon Liambotis wrote:
> Unfortunately, that workaround doesn't work so well when you want to
> have the ability to plug real orinoco (hermes) cards to your computer...
> In other words and unless I'm missing something, there isn't currently a
> way to have a Hermes card and a Prism II card both plugged in and working.

Do you know about /sys/bus/pci/drivers/*/bind and unbind?

http://lwn.net/Articles/143397/

-- 
Jiri Benc
SUSE Labs
