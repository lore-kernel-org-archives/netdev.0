From: "David S. Miller" <davem@redhat.com>
Subject: Re: Network oops
Date: Thu, 20 Jun 2002 17:38:05 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <aett13$7c5$2@main.gmane.org>
References: <20020609.213150.32126725.davem@redhat.com>
	<3D042F8F.72764243@mvista.com>
	<3D120EAE.5A0D365E@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi, andrew.r.cress@intel.com
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3D120EAE.5A0D365E@mvista.com>
List-Id: netdev.vger.kernel.org


I don't understand, you've completely turned the preemption model of
the kernel upside down and you want _US_ to debug this for you?

This is a lot of work, work I personally don't have time for.
It requires a full audit of the networking in the new preemption
environment.
