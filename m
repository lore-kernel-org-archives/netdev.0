From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Tue, 20 May 2003 07:47:44 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030520074352.N40831@shell.cyberus.ca>
References: <Pine.LNX.4.44.0305200800380.26787-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, sim@netnation.com,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0305200800380.26787-100000@netcore.fi>
List-Id: netdev.vger.kernel.org



On Tue, 20 May 2003, Pekka Savola wrote:

> On Mon, 19 May 2003, Jamal Hadi wrote:
> > I dont think the hashes are similar - its the effect into the
> > slow path. I was told by someone who tested this on a priicey CISCO
> > that they simply die unless capable of a feature called CEF.
>
> Yes, but pretty much nobody is using Cisco without CEF, except in the last
> mile, low-end devices.
>

so not a GSR thing only feature. At the edges though, wouldnt it be
important to do more sexy things than just route based on a destination
address?

cheers,
jamal
