From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Mon, 19 May 2003 22:13:33 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030519220409.V39658@shell.cyberus.ca>
References: <20030520011053.GB10419@netnation.com> <20030519.181405.35017608.davem@redhat.com>
 <20030519212209.P39592@shell.cyberus.ca> <20030519.182410.10302536.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: sim@netnation.com, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030519.182410.10302536.davem@redhat.com>
List-Id: netdev.vger.kernel.org




I dont think the hashes are similar - its the effect into the
slow path. I was told by someone who tested this on a priicey CISCO
that they simply die unless capable of a feature called CEF.

cheers,
jamal

On Mon, 19 May 2003, David S. Miller wrote:

>    From: Jamal Hadi <hadi@shell.cyberus.ca>
>    Date: Mon, 19 May 2003 21:23:08 -0400 (EDT)
>
>    Also used to attack CISCOs by them kiddies btw. We stand much better
>    than any CISCO doing caching.
>
> I have to assume that the source address selection operates
> differently for attacking cisco equiptment, our hashes being
> identical would really be unbelievable :-)
>
>
>
