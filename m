From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] net/decnet/: misc possible cleanups
Date: Sat, 18 Dec 2004 01:50:27 +0100
Message-ID: <20041218005027.GC21288@stusta.de>
References: <20041214125838.GC23151@stusta.de> <20041214133235.GB10131@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: patrick@tykepenguin.com, Steve Whitehouse <SteveW@ACM.org>,
	linux-decnet-user@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262803AbULRAut@vger.kernel.org>
To: Steven Whitehouse <steve@chygwyn.com>
Content-Disposition: inline
In-Reply-To: <20041214133235.GB10131@souterrain.chygwyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2004 at 01:32:35PM +0000, Steven Whitehouse wrote:

> Hi,

Hi Steven,

>...
> Also, when I was writing the routing code - a lot of the design was "borrowed"
> from the ipv4 routing code. It might be worth doing a comparison to see where
> the two have diverged (something I used to do now and again) to pick up any
> bugs I'd inadvertently copied over, if you are working on clean ups in this
> area,

unfortunately, I'm not working especially in this area.

I'm currently going through the complete kernel sources searching for 
global code that can be made static or even removed.

> Steve.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
