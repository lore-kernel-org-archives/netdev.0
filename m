From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 13:13:24 -0700 (PDT)
Message-ID: <20080813.131324.32902022.davem@davemloft.net>
References: <200808121521.10101.divy@chelsio.com>
	<48A32976.7060504@vlnb.net>
	<48A33633.20800@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vst@vlnb.net, open-iscsi@googlegroups.com, rdreier@cisco.com,
	rick.jones2@hp.com, swise@opengridcomputing.com, kxie@chelsio.com,
	netdev@vger.kernel.org, michaelc@cs.wisc.edu, daisyc@us.ibm.com,
	wenxiong@us.ibm.com, bhua@us.ibm.com, dm@chelsio.com,
	leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <48A33633.20800@pobox.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Wed, 13 Aug 2008 15:29:55 -0400

> * direct data placement is possible without offloading the entire TCP 
> stack onto a firmware/chip.

I've even described in this thread how that's possible.
