From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: 23 Jul 2004 16:25:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1090614331.1220.50.camel@jzny.localdomain>
References: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
	 <20040722.200426.99255296.yoshfuji@linux-ipv6.org>
	 <1090593676.1128.25.camel@jzny.localdomain>
	 <20040723.110007.27520072.yoshfuji@linux-ipv6.org>
	 <20040723092111.44b289a9@dell_ss3.pdx.osdl.net>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org>,
        "David S. Miller" <davem@redhat.com>, arekm@pld-linux.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040723092111.44b289a9@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-07-23 at 12:21, Stephen Hemminger wrote:

> Looking at the netlink style, wouldn't it make sense to add additional
> separate payloads for the new features.  This keeps the API the same and
> the kernel can easily adapt for new/old values.

If things were perfect this is the way to go. Maybe in 2.7 we can start
scrubbing some of this issues.

cheers,
jamal
