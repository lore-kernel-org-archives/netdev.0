From: David Miller <davem@davemloft.net>
Subject: Re: [PULL net-next] vhost-net fixes for 3.1
Date: Tue, 19 Jul 2011 10:15:23 -0700 (PDT)
Message-ID: <20110719.101523.1871252598458531315.davem@davemloft.net>
References: <20110719114741.GA5827@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mashirle@us.ibm.com
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab1GSRPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 13:15:33 -0400
In-Reply-To: <20110719114741.GA5827@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 19 Jul 2011 14:47:41 +0300

> Here's Jason's fix for a theoretical event loss
> on migration (tweaked by me to update the test
> module as well), and a refcounting fix by me
> for a bug in the new zerocopy mode.
> 
> I thought hard about merging Jason's patches for 3.0
> as well, but in the end I think it's not worth
> the risk of breaking something at this stage.
> 
> Please pull for 3.1, thanks a lot!

Pulled, thanks!
