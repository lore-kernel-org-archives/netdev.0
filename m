From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio_net and SMP guests
Date: Fri, 11 Jan 2008 20:53:00 +1100
Message-ID: <200801112053.01861.rusty@rustcorp.com.au>
References: <200712141312.05562.borntraeger@de.ibm.com> <200801101639.15995.borntraeger@de.ibm.com> <200801101651.58908.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, Anthony Liguori <aliguori@us.ibm.com>,
	Dor Laor <dor.laor@qumranet.com>
To: virtualization@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38483 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756551AbYAKJxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 04:53:42 -0500
In-Reply-To: <200801101651.58908.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 11 January 2008 02:51:58 Christian Borntraeger wrote:
> What about the following patch:

Looks correct and in fact pretty orthodox.

I've folded this in, thanks!

Rusty.
