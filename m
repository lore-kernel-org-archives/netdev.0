From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 19 Jun 2007 07:50:07 +0200
Message-ID: <20070619055007.GB1649@ff.dom.local>
References: <4bacf17f0706161435g1bb7c08bpd427901f64d57fa@mail.gmail.com> <20070618110849.GA2450@ff.dom.local> <20070618081000.14da5186@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070618081000.14da5186@localhost.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 18, 2007 at 08:10:00AM -0700, Stephen Hemminger wrote:
> On Mon, 18 Jun 2007 13:08:49 +0200
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > On 16-06-2007 23:35, Marcin .lusarz wrote:
> > > hi
> > > after upgrading kernel from 2.6.20 to 2.6.21.3 i'm experiencing really
> > > strange problem - my _both_ network cards dies after random uptime -
> > > sometimes it's a few minutes, sometimes hours, sometimes it does not
> > > happen for a couple of days...
> > > today it happened for the first time without nvidia module and almost
> > > immediately after system start
> > > 
> > > here is the output of some commands which might help debug this:
...
> > It looks like skge driver enables different device than probbed.
> > Maybe you've something old/wrong about eth0/eth1 in /etc configs?
> 
> More likely it is just user level device renaming. Most distro's
> rename devices (if needed) using udev.

On the other hand it's interesting, why it's not always, and why
sometimes it took so long?

Jarek P. 
