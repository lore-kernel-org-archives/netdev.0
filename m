From: David Miller <davem@davemloft.net>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 24 Jan 2012 23:02:03 -0500 (EST)
Message-ID: <20120124.230203.1478271172075708903.davem@davemloft.net>
References: <20120123.134352.1621146585245670953.davem@davemloft.net>
	<CAGsizzJnQ6b6eSC0ZnAtFguU7_xDfWFPSY6L4DWXc24F+Ts2XQ@mail.gmail.com>
	<CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steweg@ynet.sk, eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joseph.glanville@orionvm.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOzFzEjE7b-Y+_vOWeBKbHDkURRcYXomSTcwB91vKHVWQxBVsg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joseph Glanville <joseph.glanville@orionvm.com.au>
Date: Wed, 25 Jan 2012 14:48:37 +1100

> The reason why this patch is useful is that it stands to be the only
> true mulitpoint L2 VPN with a kernel space forwarding plane.

So what you're telling me is that I added this huge openvswitch
thing essentially for nothing?
