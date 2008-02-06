From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: Fix open <-> interrupt race
Date: Wed, 6 Feb 2008 15:00:03 +1100
Message-ID: <200802061500.04138.rusty@rustcorp.com.au>
References: <200802051436.10841.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dor.laor@qumranet.com,
	Anthony Liguori <aliguori@us.ibm.com>,
	virtualization@lists.linux-foundation.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44341 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759140AbYBFEAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 23:00:11 -0500
In-Reply-To: <200802051436.10841.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 February 2008 00:36:10 Christian Borntraeger wrote:
> I got the following oops during interface ifup. Unfortunately its not
> easily reproducable so I cant say for sure that my fix fixes this
> problem, but I am confident and I think its correct anyway:

Looks fine, and certainly shouldn't hurt.  Please push this out.

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.
