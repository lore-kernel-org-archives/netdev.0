From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 29 Jul 2004 07:30:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091100602.1043.557.camel@jzny.localdomain>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	 <1090593676.1128.25.camel@jzny.localdomain>
	 <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
	 <1090612669.1218.47.camel@jzny.localdomain>
	 <20040723135945.7f50b02c.davem@redhat.com>
	 <1090630154.1134.6.camel@jzny.localdomain>
	 <1090675993.1161.11.camel@jzny.localdomain>
	 <20040724222853.752137d6.davem@redhat.com>
	 <1091100138.1044.549.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, shemminger@osdl.org, arekm@pld-linux.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1091100138.1044.549.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Patch was against 2.6.8-rc2 not bk20.

cheers,
jamal

On Thu, 2004-07-29 at 07:22, jamal wrote:
> On Sun, 2004-07-25 at 01:28, David S. Miller wrote:
> 
> > Ok, I'll keep this in my inbox until you give the word.
> 
> [Still trying to recover after all those conferences].
> 
> Heres a patch that passes all my regression tests. I use a 
> __u64 instead of u64 for perf counters since user space understands it.
> 
> cheers,
> jamal
> 
> PS:- at some point we need to scrub the general backward compatibility
> issues going forward. 
