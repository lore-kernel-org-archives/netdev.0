From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 8 Sep 2010 11:13:26 +0300
Message-ID: <20100908081326.GD23051@redhat.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758390Ab0IHITc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 04:19:32 -0400
Content-Disposition: inline
In-Reply-To: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 08, 2010 at 12:58:59PM +0530, Krishna Kumar wrote:
> 1. mq RX patch is also complete - plan to submit once TX is OK.

It's good that you split patches, I think it would be interesting to see
the RX patches at least once to complete the picture.
You could make it a separate patchset, tag them as RFC.

-- 
MST
