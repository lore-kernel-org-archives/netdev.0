From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 22:27:10 +0200
Message-ID: <20110518202710.GD4175@nuttenaction>
References: <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
 <20110518.155200.801089483916944725.davem@davemloft.net>
 <20110518202025.GC4175@nuttenaction>
 <20110518.162306.441229167098643303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsunanet@gmail.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110518.162306.441229167098643303.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller | 2011-05-18 16:23:06 [-0400]:

>Then this gets back to the fact that this is a network
>attribute and thus more suitable as a route metric not
>a global system-wide sysctl.

Yes, in an Email response to Eric I mentioned this already. The initial RTO is
a perfect candidate for route metric. I waiting for a patch to test it! ;-)

Hagen
