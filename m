From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: iproute2 and kernel headers
Date: Tue, 03 Aug 2004 00:55:42 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803.005542.104434029.yoshfuji@linux-ipv6.org>
References: <20040802153805.487f832f@dell_ss3.pdx.osdl.net>
	<20040802160445.5ef3b251.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@znyx.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, shemminger@osdl.org
In-Reply-To: <20040802160445.5ef3b251.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040802160445.5ef3b251.davem@redhat.com> (at Mon, 2 Aug 2004 16:04:45 -0700), "David S. Miller" <davem@redhat.com> says:

> > What headers really seem to change a lot? The obvious ones are:
> > 
> > 	linux/pkt_sched.h
> > 	linux/tcp_diag.h
> > 	linux/xfrm.h
> 
> I would add linux/rtnetlink.h

Then, linux/snmp.h.

--yoshfuji
