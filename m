From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Extend netlink error codes
Date: Mon, 13 Sep 2004 16:28:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913162811.1b0a45c8.davem@davemloft.net>
References: <20040910225158.GO20088@postel.suug.ch>
	<20040911155839.GN4431@wotan.suse.de>
	<20040911162433.GC21181@postel.suug.ch>
	<3A0D075D-0423-11D9-BBE1-000A95AD0668@errno.com>
	<1094937035.2344.189.camel@jzny.localdomain>
	<20040913203657.GF23686@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, sam@errno.com, ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040913203657.GF23686@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 22:36:57 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> > BTW, there was someone from IBM a while back who was talking about
> > having drivers send error messages via netlink; someone needs to look at
> > the ideas they have maybe we can borrow something.
> 
> http://lwn.net/Articles/39164/

I think since the inclusion of IBM's work is iffy at best,
we should architect our facility without assuming it's presence.
