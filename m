From: David Miller <davem@davemloft.net>
Subject: Re: [patch v4, kernel version 3.2.1] net/ipv4/ip_gre: Ethernet
 multipoint GRE over IP
Date: Wed, 25 Jan 2012 20:37:46 -0500 (EST)
Message-ID: <20120125.203746.1977019610549185259.davem@davemloft.net>
References: <CAEP_g=9H9dV9=qtFPh4YeTNQ-t+UZGw-YqZ6hFWVNXjFy+GCZg@mail.gmail.com>
	<20120125.165548.596418893115900979.davem@davemloft.net>
	<CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, joseph.glanville@orionvm.com.au,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGsizzJnRy74ni-HH=5q1VR4g6sfDPg9SFw4UKgSjJjkSR8OJA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =A6tefan Gula <steweg@ynet.sk>
Date: Wed, 25 Jan 2012 23:57:18 +0100

> The performance is one of the most critical thing why I have chosen t=
o
> build kernel patch in the first place instead of some user-space app.
> If I used this approach, I would probably end up with patch for
> OpenVPN project instead in that time. I am not telling that
> openvswitch is not a good place for prototyping, but I believe that
> this patch is beyond that border as it successfully run in environmen=
t
> with more 98 linux-based APs, used for 4K+ users, with no issue for
> more than 2 years. The performance results from Joseph Glanville even
> adds value to it. So I still don't get the point, why my patch and
> openvswitch cannot coexists in the kernel together and let user/admin
> to choose to correct solution for him/her.

You don't even know if openvswitch could provide acceptable levels
of performance, because you haven't even tried.

I'm not applying your patch.
