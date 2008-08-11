From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Mon, 11 Aug 2008 14:52:14 -0700 (PDT)
Message-ID: <20080811.145214.146849230.davem@davemloft.net>
References: <adafxpbzga0.fsf@cisco.com>
	<20080811.140838.202229941.davem@davemloft.net>
	<adahc9rxmcc.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, swise@opengridcomputing.com, divy@chelsio.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adahc9rxmcc.fsf@cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 11 Aug 2008 14:39:47 -0700

>  > > Yes, that's the question -- are stateless offloads (plus CRC32C in the
>  > > CPU etc) going to give good enough performance that the whole TCP
>  > > offload exercise is pointless?
>  > 
>  > This is by definition true, over time.  And this has stedfastly proven
>  > itself, over and over again.
> 
> By the definition of what?

By definition of time always advancing forward, and cpus always
getting faster, and memory (albeit more slowly) increasing in
speed too,

