From: bert hubert <ahu@ds9a.nl>
Subject: Re: [PATCH 2.6] iptables CLUSTERIP target
Date: Thu, 21 Oct 2004 17:08:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021150856.GA27191@outpost.ds9a.nl>
References: <20041020223828.GP19899@sunbeam.de.gnumonks.org> <20041021075530.GA1278@infradead.org> <20041021091229.GA3551@sunbeam.de.gnumonks.org> <20041021110513.GA21579@outpost.ds9a.nl> <20041021130327.GD3551@sunbeam.de.gnumonks.org> <20041021133346.GL3911@marowsky-bree.de> <20041021142527.GG3551@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lars Marowsky-Bree <lmb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
Content-Disposition: inline
In-Reply-To: <20041021142527.GG3551@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 21, 2004 at 04:25:27PM +0200, Harald Welte wrote:

> I'm not a big fan of inventing new kernel/userspace interfaces.  We
> don't have any associated device, so we don't have any ioctl()s or stuff
> like that.

Or use netlink.

> So instead of introducing a new syscall, I think /proc is just the right
> way to deal with this :)

Or even more modern, clusteripfs.

> Let me give it some testing, I'll re-submit it later today or tomorrow.

I'll test it at home to see if it does the right thing too.

> > > > And yes, I've received hate mail over this from switch engineers :-)

The hate mail originated from a large telco, I think the innovation just
offended their sensitive minds.

	Bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
