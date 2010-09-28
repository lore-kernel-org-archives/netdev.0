From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 0/4] cxgbi: bug fixes and driver update
Date: Tue, 28 Sep 2010 15:45:15 -0500
Message-ID: <4CA253DB.8040408@cs.wisc.edu>
References: <201009232343.o8NNhN0E006459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com, rranjan@chelsio.com,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net
To: kxie@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:33936 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751236Ab0I1UjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 16:39:14 -0400
In-Reply-To: <201009232343.o8NNhN0E006459@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2010 06:43 PM, kxie@chelsio.com wrote:
> [PATCH 0/4] cxgbi: bug fixes and driver update
>
> From: Karen Xie<kxie@chelsio.com>
>
> This patchset includes:
> - renamed alloc_cpl() to alloc_wr(),
> - fixed locking in pdu read,
> - fixed cxgb3i connecting over VLAN, and
> - updated cxgb4i connection setting and ddp programming.
>

Looks ok.

Reviewed-by: Mike Christie <michaelc@cs.wisc.edu>
