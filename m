From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: kvm networking todo wiki
Date: Tue, 21 Sep 2010 18:11:24 +0200
Message-ID: <20100921161124.GC22845@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, qemu-devel@nongnu.org, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>, sri@linux.vnet.ibm.com,
	Anthony Liguori <anthony@codemonkey.ws>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Sh
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1188 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754215Ab0IUQRi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 12:17:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've put up a wiki page with a kvm networking todo list,
mainly to avoid effort duplication, but also in the hope
to draw attention to what I think we should try addressing
in KVM:

http://www.linux-kvm.org/page/NetworkingTodo

This page could cover all networking related activity in KVM,
currently most info is related to virtio-net.

Note: if there's no developer listed for an item,
this just means I don't know of anyone actively working
on an issue at the moment, not that no one intends to.

I would appreciate it if others working on one of the items on this list
would add their names so we can communicate better.  If others like this
wiki page, please go ahead and add stuff you are working on if any.

It would be especially nice to add autotest projects:
there is just a short test matrix and a catch-all
'Cover test matrix with autotest', currently.

Currently there are some links to Red Hat bugzilla entries,
feel free to add links to other bugzillas.

Thanks!

-- 
MST
