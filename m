From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: IPSEC and MPLS priority for 2.6?
Date: Thu, 18 Dec 2003 16:55:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031218.165541.57234428.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0312180930560.12194-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0312180930560.12194-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0312180930560.12194-100000@netcore.fi> (at Thu, 18 Dec 2003 09:36:15 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/must-fix/should-fix-7.txt
> [see below]
> 
> .. I don't agree.  MPLS is only needed for IPsec VPNs in the case that 
> Linux is being used as an MPLS router, like as Provider Edge device.  
> I think it's safe to say this is close to a marginal application of 
> Linux.  I don't think this is Priority 1 ("we're totally lame if we 
> don't do it") thing -- at least from the IPsec perspective.  I'd 
> suggest pushing it down in the priority list.

seconded.

--yoshfuji
