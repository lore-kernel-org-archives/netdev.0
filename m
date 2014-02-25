From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2 2/4] net: enables interface option to skip IP
Date: Mon, 24 Feb 2014 19:12:38 -0500 (EST)
Message-ID: <20140224.191238.921310808350170272.davem@davemloft.net>
References: <1393266120.8041.19.camel@dcbw.local>
	<20140224.180426.411052665068255886.davem@davemloft.net>
	<1393286520.6823.123.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, mcgrof@do-not-panic.com, zoltan.kiss@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393286520.6823.123.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 25 Feb 2014 00:02:00 +0000

> You can run an internal network, or access network, as v6-only with
> NAT64 and DNS64 at the border.  I believe some mobile networks are doing
> this; it was also done on the main FOSDEM wireless network this year.

This seems to be bloating up the networking headers of the internal
network, for what purpose?

For mobile that's doubly inadvisable.
