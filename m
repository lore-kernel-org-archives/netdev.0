From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] schedule SHAPER for removal
Date: Sat, 21 Jan 2006 01:48:48 +0100
Message-ID: <20060121004848.GM31803@stusta.de>
References: <20060119021150.GC19398@stusta.de> <20060119215722.GO16285@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932360AbWAUAsx@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060119215722.GO16285@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 19, 2006 at 04:57:22PM -0500, Benjamin LaHaise wrote:
> On Thu, Jan 19, 2006 at 03:11:50AM +0100, Adrian Bunk wrote:
> > +What:   Traffic Shaper (CONFIG_SHAPER)
> > +When:   July 2006
> > +Why:    obsoleted by the code in net/sched/
> > +Who:    Adrian Bunk <bunk@stusta.de
> 
> This length of obsolete cycles is way too short -- it's not even enough 
> time for a single release of a distro to ship with the feature marked as 
> obsolete.

Do we really have to wait the three years between stable Debian releases 
for removing an obsolete driver that has always been marked as 
EXPERIMENTAL?

Please be serious.

> 		-ben

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
