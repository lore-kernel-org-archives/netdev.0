From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 0/5] macvtap fixes.
Date: Fri, 21 Oct 2011 02:56:07 -0400 (EDT)
Message-ID: <20111021.025607.2193225431127507358.davem@redhat.com>
References: <m1wrbzu4ec.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arnd.de, jasowang@redhat.com,
	mst@redhat.com, ian.campbell@citrix.com, mashirley@us.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751124Ab1JUG4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 02:56:18 -0400
In-Reply-To: <m1wrbzu4ec.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 20 Oct 2011 07:24:59 -0700

> 
> This series of patches fixes a series of minor bugs in the macvtap code.
> 
> The fixes to handle failures in newlink and the change in how we handle
> minor device number allocations are particularly significant.

Applied to net-next, thanks.
