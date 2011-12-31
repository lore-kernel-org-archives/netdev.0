From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] IPv6: Avoid taking write lock for
 /proc/net/ipv6_route
Date: Sat, 31 Dec 2011 17:46:05 -0500 (EST)
Message-ID: <20111231.174605.901317517736513953.davem@davemloft.net>
References: <CAKA=qzbZ4x5u1bBM0gAECeMNutyaVzp1FmRPwKHsBEEs7984ag@mail.gmail.com>
	<20111230.170905.1348056803377924696.davem@davemloft.net>
	<CAKA=qzb=PYTMO=9KFpTJ9BVdDRkqbaCuW02pbW0onM8gU1E7sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joshhunt00@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKA=qzb=PYTMO=9KFpTJ9BVdDRkqbaCuW02pbW0onM8gU1E7sw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Hunt <joshhunt00@gmail.com>
Date: Sat, 31 Dec 2011 13:49:38 -0600

> Thanks David. Are you aware if anyone has started the work to make
> IPv6 traversals RCU safe?

Nobody is working on this.
