From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: Route cache performance under stress
Date: 22 May 2003 15:03:07 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1053608586.9475.60.camel@tux.rsn.bth.se>
References: <20030520.173607.88482742.davem@redhat.com>
	 <20030522084003.GA22613@netnation.com>
	 <20030522.015815.91322249.davem@redhat.com>
	 <20030522.034058.71558626.davem@redhat.com>
	 <20030522114438.GD2961@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030522114438.GD2961@netnation.com>
List-Id: netdev.vger.kernel.org

On Thu, 2003-05-22 at 13:44, Simon Kirby wrote:

> Nice!  I tested with 300,000 routing table entries and there is no
> discernable difference in performance from having an empty table. 
> vmstat shows the same idle time as when the routing table is empty.

How much memory does a table that large use?

-- 
/Martin
