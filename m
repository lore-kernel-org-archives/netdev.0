From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 08:01:32 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0305200800380.26787-100000@netcore.fi>
References: <20030519220409.V39658@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <sim@netnation.com>,
	<netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030519220409.V39658@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Mon, 19 May 2003, Jamal Hadi wrote:
> I dont think the hashes are similar - its the effect into the
> slow path. I was told by someone who tested this on a priicey CISCO
> that they simply die unless capable of a feature called CEF.

Yes, but pretty much nobody is using Cisco without CEF, except in the last 
mile, low-end devices.

> On Mon, 19 May 2003, David S. Miller wrote:
> 
> >    From: Jamal Hadi <hadi@shell.cyberus.ca>
> >    Date: Mon, 19 May 2003 21:23:08 -0400 (EDT)
> >
> >    Also used to attack CISCOs by them kiddies btw. We stand much better
> >    than any CISCO doing caching.
> >
> > I have to assume that the source address selection operates
> > differently for attacking cisco equiptment, our hashes being
> > identical would really be unbelievable :-)
> >
> >
> >
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

