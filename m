From: Rob Landley <rob@landley.net>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Sat, 23 Feb 2013 14:05:42 -0600
Message-ID: <1361649942.11282.13@driftwood>
References: <20130219150500.GG4390@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: Arnd Bergmann <arnd@arndb.de>, balbi@ti.com,
	kishon <kishon@ti.com>, tony@atomide.com, linux@arm.linux.org.uk,
	eballetbo@gmail.com, javier@dowhile0.org,
	gregkh@linuxfoundation.org, akpm@linux-foundation.org,
	mchehab@redhat.com, cesarb@cesarb.net, davem@davemloft.net,
	santosh.shilimkar@ti.com, broonie@opensource.wolfsonmicro.com,
	swarren@nvidia.com, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: balbi@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130219150500.GG4390@arwen.pp.htv.fi> (from balbi@ti.com on
	Tue Feb 19 09:05:00 2013)
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/19/2013 09:05:00 AM, Felipe Balbi wrote:
> Greg, can you pitch your suggestion here ? It would be great to hear
> your rationale behind dropping class infrastructure, couldn't find
> anything through Google and since feature-removal-schedule.txt has  
> been
> removed (without adding it to feature-removal-schedule.txt, I must add
> :-) I don't know what's the idea behind removing classes.

I actually went through and poked a couple of people about old entries  
in feature-removal-shedule.txt last year, but I haven't been very  
active since the kernel.org breakin because my account got disabled,  
and I needed to meet kernel developers in person to get keys signed to  
get it switched back on (or set up a separate git tree with signed  
commits -next could pull from).

I don't get out much; as a consultant I have to take time off from work  
and pay for my own travel and lodging. So I've been to exactly two  
conferences in the past 3 years: last year's Texas Linux Fest (my house  
got broken into and a netbook with the key on it stolen the following  
wednesday), and CELF (which I'm on the plane back from now, Greg KH  
signed my key! Woo!).

If I can use that to get my account back, set up a tree feeding into  
linux-next, and maybe even recover the ability to update  
http://kernel.org/doc, I'd happily field some sort of  
feature-removal-schedule list and make sure it stays current. (Linus  
didn't ask me about removing the old one, I found out about it from the  
git log. But I can't blame him, I haven't exactly been tearing through  
the bureaucracy to get my access back. "Volunteer work" and "painful"  
tend not to combine well on my todo list in terms of scheduling  
priority...)

Rob