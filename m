From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] vhost: fix get_user_pages_fast error handling
Date: Tue, 23 Feb 2010 14:42:35 -0800 (PST)
Message-ID: <20100223.144235.08984181.davem@davemloft.net>
References: <20100223173434.GB9834@redhat.com>
	<20100223173258.GA25338@redhat.com>
	<20100223173952.GC9834@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, rusty@rustcorp.com.au, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, markmc@redhat.com,
	herbert.xu@redhat.com, quintela@redhat.com, dlaor@redhat.com,
	avi@redhat.com
To: gleb@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100223173952.GC9834@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just for the record I'm generally not interested in vhost
patches.

If it's a specific network one that will be merged via
the networking tree, yes please CC: me.

But if it's a bunch of changes to vhost.c and other pieces
of infrastructure, feel free to leave me out of it.  It just
clutters my already overflowing inbox.

Thanks.
