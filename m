From: Andrew Morton <akpm@osdl.org>
Subject: Re: e1000: "fix" it on thinkpad x60 / eeprom checksum read fails
Date: Fri, 21 Jul 2006 17:21:11 -0700
Message-ID: <20060721172111.51419511.akpm@osdl.org>
References: <20060721005832.GA1889@elf.ucw.cz>
	<44BFADA6.6090909@intel.com>
	<20060720170758.GA9938@atrey.karlin.mff.cuni.cz>
	<44BFBE9F.7070600@intel.com>
	<20060721064105.aa960acd.akpm@osdl.org>
	<20060721151239.GC2290@thunk.org>
	<44C0F13E.2030008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, auke-jan.h.kok@intel.com, pavel@ucw.cz,
	cramerj@intel.com, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42140 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750767AbWGVAV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 20:21:27 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44C0F13E.2030008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Jul 2006 08:22:38 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> > And if someone who understands all of these details could put a note
> > in the thinkwiki (say, here:
> > http://www.thinkwiki.org/wiki/Ethernet_Controllers#Intel_Gigabit_.2810.2F100.2F1000.29)
> > it would be greatly appreciated.
> > 
> 
> why don't I do that :)
> 
> 
> Andrew: I'm contemplating that printk...

Print the wiki URL ;)
