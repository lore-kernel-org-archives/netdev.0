From: "David S. Miller" <davem@redhat.com>
Subject: Re: iproute2 and kernel headers
Date: Tue, 3 Aug 2004 14:21:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803142151.11d130ee.davem@redhat.com>
References: <20040802153805.487f832f@dell_ss3.pdx.osdl.net>
	<20040802160445.5ef3b251.davem@redhat.com>
	<20040803.005542.104434029.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: shemminger@osdl.org, hadi@znyx.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040803.005542.104434029.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 00:55:42 -0700 (PDT)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20040802160445.5ef3b251.davem@redhat.com> (at Mon, 2 Aug 2004 16:04:45 -0700), "David S. Miller" <davem@redhat.com> says:
> 
> > > What headers really seem to change a lot? The obvious ones are:
> > > 
> > > 	linux/pkt_sched.h
> > > 	linux/tcp_diag.h
> > > 	linux/xfrm.h
> > 
> > I would add linux/rtnetlink.h
> 
> Then, linux/snmp.h.

Agreed.
