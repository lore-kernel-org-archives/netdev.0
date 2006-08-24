From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][REPOST] WAN: fix C101 card carrier handling
Date: Wed, 23 Aug 2006 23:39:52 -0400
Message-ID: <44ED1F88.20304@garzik.org>
References: <m3k651udsq.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:5346 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030258AbWHXDj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 23:39:56 -0400
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3k651udsq.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Hi,
> 
> One of my recent changes broke C101 carrier handling, this patch
> fixes it. Also fixes an old TX underrun checking bug.
> 
> 2.6.18 material. Please apply.

it's already in netdev-2.6.git#upstream-fixes, destined for 2.6.18.

	Jeff



