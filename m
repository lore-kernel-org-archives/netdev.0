From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:39:47 -0700
Message-ID: <adahc9rxmcc.fsf@cisco.com>
References: <adazlnlzc60.fsf@cisco.com>
	<20080809.224637.69833549.davem@davemloft.net>
	<adafxpbzga0.fsf@cisco.com>
	<20080811.140838.202229941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20080811.140838.202229941.davem@davemloft.net> (David Miller's
	message of "Mon, 11 Aug 2008 14:08:38 -0700 (PDT)")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > > Yes, that's the question -- are stateless offloads (plus CRC32C in the
 > > CPU etc) going to give good enough performance that the whole TCP
 > > offload exercise is pointless?
 > 
 > This is by definition true, over time.  And this has stedfastly proven
 > itself, over and over again.

By the definition of what?

 - R.
