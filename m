From: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Subject: Re: oops with recent wireless-dev tree
Date: Thu, 30 Aug 2007 09:45:13 -0600
Message-ID: <20070830154513.GV14130@parisc-linux.org>
References: <20070829223752.GA6969@seehuhn.de> <1188475530.2963.20.camel@johannes.berg> <20070830074949.7cd25b04@freepuppy.rosehill.hemminger.net> <1188486091.3978.32.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jochen Voss <voss-52ZyvxujusuELgA04lAiVw@public.gmane.org>,
	linux wireless list <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bridge-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1188486091.3978.32.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 30, 2007 at 05:01:31PM +0200, Johannes Berg wrote:
> Jochen had a patch: http://marc.info/?l=linux-wireless&m=118842715026614&w=2

That's exactly the right patch, please add

Acked-by: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>

I just checked over the commit that introduced the bug, and I didn't
make the same mistake anywhere else.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
