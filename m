From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RFC: [2.6 patch] disallow modular IPv6
Date: Tue, 30 Sep 2003 11:14:26 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064916865.21551.114.camel@hades.cambridge.redhat.com>
References: <20030928225941.GW15338@fs.tum.de>
	 <20030928231842.GE1039@conectiva.com.br> <20030928232403.GX15338@fs.tum.de>
	 <20030929220916.19c9c90d.davem@redhat.com>
	 <1064903562.6154.160.camel@imladris.demon.co.uk>
	 <20030930000302.3e1bf8bb.davem@redhat.com>
	 <1064907572.21551.31.camel@hades.cambridge.redhat.com>
	 <20030930010855.095c2c35.davem@redhat.com>
	 <1064910398.21551.41.camel@hades.cambridge.redhat.com>
	 <20030930013025.697c786e.davem@redhat.com>
	 <1064911360.21551.49.camel@hades.cambridge.redhat.com>
	 <20030930015125.5de36d97.davem@redhat.com>
	 <1064913241.21551.69.camel@hades.cambridge.redhat.com>
	 <20030930022410.08c5649c.davem@redhat.com>
	 <1064916168.21551.105.camel@hades.cambridge.redhat.com>
	 <20030930030153.6510dbae.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, acme@conectiva.com.br, netdev@oss.sgi.com,
        pekkas@netcore.fi, lksctp-developers@lists.sourceforge.net,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030930030153.6510dbae.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-09-30 at 03:01 -0700, David S. Miller wrote:
> Then let's agree to disagree.

That's what I suggested 50 minutes ago :)

As I said, it's a matter of taste. The idea that CONFIG_xxx_MODULE
should be removed from visibility during the vmlinux build is not
limited to myself and Adrian alone. We can revisit it during 2.7
development.

I won't be spending time on it myself at least until after sleep_on() is
already dead, but I'm sure someone will offer it as a 'cleanup'.

-- 
dwmw2
