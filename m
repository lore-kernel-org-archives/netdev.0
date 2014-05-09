From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Fri, 9 May 2014 11:48:13 +0200
Message-ID: <20140509094813.GC4877@xo-6d-61-c0.localdomain>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: josh@joshtriplett.org, andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	ak@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140506.115941.428706504757835279.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue 2014-05-06 11:59:41, David Miller wrote:
> From: josh@joshtriplett.org
> Date: Tue, 6 May 2014 08:57:03 -0700
> 
> > On Mon, May 05, 2014 at 11:23:27PM -0400, David Miller wrote:
> >> From: Andi Kleen <andi@firstfloor.org>
> >> Date: Tue, 6 May 2014 05:21:14 +0200
> >> 
> >> > What parts would you remove to get the foot print down for a 2MB
> >> > single purpose machine?
> >> 
> >> I wouldn't use Linux, end of story.
> >> 
> >> Maybe two decades ago, but not now, those days are over.
> > 
> > That's a self-fulfilling prophecy:
> 
> Making 2MB RAM machines today makes no sense at all.
> 
> The lowest end dirt cheap smartphone, something which fits on
> someone's pocket, has gigabytes of ram.

Low end smartphone is quite high-end device :-). It only has to run for
few days on big battery.

I have programmable watch with <64K RAM. Yes, that one runs for months on
battery. 

> The only entity looking backwards are the people making these
> improperly provisioned systems.

There's nothing improper about small ammount of RAM to save power.

									Pavel



-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
