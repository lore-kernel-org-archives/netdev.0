From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 4/5] sis900 printk and stack usage audit
Date: Sun, 12 Dec 2004 09:23:34 +0100
Message-ID: <20041212082334.GC3084@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110835.GE31707@picchio.gall.it> <41BB4651.4040106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41BB4651.4040106@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Dec 11, 2004 at 02:11:13PM -0500, Jeff Garzik wrote:
> This is a step backwards.
> 
> You are _adding_ multiple copies of the same piece of code, just to 
> avoid calling a function.

Ok, I'm learning what is good and what is bad. Patch dropped.

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
