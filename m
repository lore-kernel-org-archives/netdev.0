From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-v01 0/7] Latest NetLabel patchset against net-2.6.19
Date: Thu, 03 Aug 2006 17:00:45 -0700 (PDT)
Message-ID: <20060803.170045.91444340.davem@davemloft.net>
References: <20060803200928.721027000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linda.knippers@hp.com, sds@tycho.nsa.gov, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51859
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030235AbWHDAAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 20:00:44 -0400
To: paul.moore@hp.com
In-Reply-To: <20060803200928.721027000@flek.zko.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Thu, 03 Aug 2006 16:09:28 -0400

> This is the NetLabel patchset backed against DaveM's net-2.6.19
> tree.  The major changes from the last version have been the
> conversion to the new LSM hooks that were introduced with the
> MLSXFRM patchset and the shift to using Netlink attributes.  I've
> also done some work to reduce the amount of overhead when categories
> are used.
>
> Please consider this for inclusion into 2.6.19.

This looks good, thanks for fixing everything up.

I've queued all 7 patches to my net-2.6.19 tree at:

	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.19.git

Thanks again.
