From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 0/2] NET: Multiple queue network device support REPOST
Date: Thu, 08 Mar 2007 22:45:08 -0800
Message-ID: <45F10274.7070500@intel.com>
References: <1173420779298-git-send-email-peter.p.waskiewicz.jr@intel.com> <20070308.222154.74746753.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, christopher.leech@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:29879 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993014AbXCIGpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 01:45:11 -0500
In-Reply-To: <20070308.222154.74746753.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> You didn't address my correction the other day wherein I clarified
> for you that my idea was not to store the queue mapping in
> skb->priority but rather to shrink skb->priority to a u16 and
> add a new u16 skb->queue_mapping or whatever field to store the
> necessary information.
> 
> You're just posting a set of patches using the same approach again
> plus some bug fixes, so there is essentially nothing new for anyone to
> review.
> 
> Why ask for feedback if you fail to take any of it into consideration?
> :-/

Where are the patches anyway? They didn't seem to make it either to netdev nor lkml!

Auke
