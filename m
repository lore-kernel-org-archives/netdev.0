From: "David S. Miller" <davem@redhat.com>
Subject: Re: Initialising net/ipv4/ before net/ipv6/ breaks IPv6 autoconf
 with nfsroot....
Date: Fri, 20 Feb 2004 11:08:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220110812.07cff16f.davem@redhat.com>
References: <1077201499.18703.381.camel@hades.cambridge.redhat.com>
	<20040219222253.082458cf.davem@redhat.com>
	<1077303776.427.575.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1077303776.427.575.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2004 19:02:57 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Thu, 2004-02-19 at 22:22 -0800, David S. Miller wrote:
> > On Thu, 19 Feb 2004 14:38:20 +0000
> > David Woodhouse <dwmw2@infradead.org> wrote:
> > 
> > > Putting IPv6 before IPv4 in net/Makefile fixes it, letting it IPv6
> > > register its notifiers before the IPv4 ipconfig code brings up the
> > > interface.
> > > 
> > > Objections?
> > 
> > No objection.  Send me a patch.
> 
> For 2.4, which is the one I've actually tested...

Also applied.

Thanks again David.
