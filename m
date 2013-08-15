From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] macvtap: Allow tap features change when
 IFF_VNET_HDR is disabled.
Date: Thu, 15 Aug 2013 15:39:49 -0700 (PDT)
Message-ID: <20130815.153949.1899943553778101815.davem@davemloft.net>
References: <20130815173347.GA10265@redhat.com>
	<20130815.131645.1042317207899492632.davem@davemloft.net>
	<20130815205245.GB12743@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab3HOWjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 18:39:49 -0400
In-Reply-To: <20130815205245.GB12743@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 15 Aug 2013 23:52:45 +0300

> OK in that case let's fix the rest of macvtap so I can stop getting
> confused?

Sure, but after you guys sort out these bug fixes.
