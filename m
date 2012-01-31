From: David Miller <davem@davemloft.net>
Subject: Re: [patch v7, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Tue, 31 Jan 2012 11:50:05 -0500 (EST)
Message-ID: <20120131.115005.1292336126288944173.davem@davemloft.net>
References: <12547555.801328015432974.JavaMail.root@5-MeO-DMT.ynet.sk>
	<4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4168018.821328016111235.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Tue, 31 Jan 2012 14:21:51 +0100 (CET)

>   - neither NVGRE nor VXLAN are part of the openvswitch for now

Too bad, it means we'll have this new user API of your's so when
openvswitch does add the necessary code we CANNOT REMOVE your stuff.

I'm not applying this until you at least attempt an openvswitch
version, and that's basically the end of this discussion.
