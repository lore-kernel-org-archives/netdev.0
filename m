From: Andi Kleen <ak@suse.de>
Subject: Re: Level One LXT1001 GE chip
Date: Thu, 27 Nov 2003 12:20:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031127122021.3ac80a86.ak@suse.de>
References: <3FC3FB99.70700@wanadoo.es>
	<20031127010324.061cac3b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: xose@wanadoo.es, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031127010324.061cac3b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Nov 2003 01:03:24 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Wed, 26 Nov 2003 02:02:17 +0100
> Xose Vazquez Perez <xose@wanadoo.es> wrote:
> 
> > http://people.freebsd.org/~wpaul/Level1/LXT1001SRM.pdf
> 
> Looks mildly interesting, I might be inspired to cook up
> a fresh driver :)

Actually there is an old vendor driver for the lxt1001
(but it is quite ugly and will probably need some porting for 2.6
or even 2.4) 

I've been also slowly working on a new driver, but still nothing
releasable.

-Andi
