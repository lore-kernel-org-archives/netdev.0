From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Sun, 12 Sep 2004 06:01:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040912100114.GB11484@havoc.gtf.org>
References: <20040908065152.GC27886@wotan.suse.de> <E1C4wYe-0005qT-00@gondolin.me.apana.org.au> <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain> <20040911142116.GL4431@wotan.suse.de> <1094933731.2343.109.camel@jzny.localdomain> <20040911174535.2acbb957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, ak@suse.de, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040911174535.2acbb957.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Oh and update Documentation/networking/netdevice.txt.

If people are going to screw with the TX path, at least do it right and
make it non-mysterious for everyone else.

See Al Viro's Documentation/filesystem/directory-locking doc for a
proper way to document a locking change that potentially affects every
net driver in the kernel.

	Jeff
