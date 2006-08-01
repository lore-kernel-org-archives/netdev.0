From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Mon, 31 Jul 2006 17:49:34 -0700
Message-ID: <ada7j1t700x.fsf@cisco.com>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
	<20060727.183415.104032934.davem@davemloft.net>
	<200608010231.58339.ak@suse.de>
	<20060731.174641.99457765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:16045 "EHLO
	sj-iport-4.cisco.com") by vger.kernel.org with ESMTP
	id S1751543AbWHAAtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 20:49:36 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060731.174641.99457765.davem@davemloft.net> (David Miller's message of "Mon, 31 Jul 2006 17:46:41 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    David> Why is this a relevant analogy?  Well, you have physical
    David> hard-disks in your computer today, but at some point that
    David> device becomes largely superfluous.  It makes more sense to
    David> have just a cpu with a 10-gigabit ethernet interface
    David> incorporated onto the cpu die, and the majority if not all
    David> of your disk access is remote.

Isn't most of the iSCSI control plane in userspace right now?

 - R.
