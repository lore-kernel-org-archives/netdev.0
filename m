From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: BUG in free_netdev() on ppp link deletion
Date: Fri, 6 Oct 2017 10:57:35 +0200
Message-ID: <20171006085735.onwxfr3ble5vhqns@alphalink.fr>
References: <20171003074413.GA26158@tp>
 <20171003164003.f5yay2oe6dhxnump@alphalink.fr>
 <20171005145503.ehv34hkzm5gtrjcp@alphalink.fr>
 <20171006080902.GA11223@tp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
        Paul Mackerras <paulus@samba.org>,
        David Ahern <dsahern@gmail.com>,
        Gao Feng <gfree.wind@vip.163.com>
To: Beniamino Galvani <bgalvani@redhat.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171006080902.GA11223@tp>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2017 at 10:09:03AM +0200, Beniamino Galvani wrote:
> On Thu, Oct 05, 2017 at 04:55:03PM +0200, Guillaume Nault wrote:
> > Sorry for the delay, I've followed a few complicated dead ends before
> > getting to this simple and rather obvious fix.
> > 
> > Can you try this patch?
> > 
> > [..]
> 
> The patch solves the issue, thanks.
> 
Thanks, I'm going to do some more tests and submit it formally.
