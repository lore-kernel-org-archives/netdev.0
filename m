From: David Miller <davem@davemloft.net>
Subject: Re: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Wed, 02 May 2012 02:44:27 -0400 (EDT)
Message-ID: <20120502.024427.22049954455309204.davem@davemloft.net>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120502055008.GA29319@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab2EBGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 02:44:34 -0400
In-Reply-To: <20120502055008.GA29319@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 2 May 2012 08:50:09 +0300

> On Wed, May 02, 2012 at 11:41:21AM +0800, Jason Wang wrote:
>> This is an updated since the last series of vhost/macvtap zerocopy fixes which
>> fixes the the possible transmission stall, host kernel stack overflow and other
>> misc fixes.
>> 
>> Changes from V1:
>> - Addressing comments from Eric and Michael.
>> - Adding more fixes into the seires.
> 
> Thanks for fixing this.
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Dave, can you merge this for 3.4 please?

It's rather late in the -RC for such a large patch set.
