From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: remove skb_orphan calls
Date: Fri, 27 Feb 2009 17:19:11 -0800 (PST)
Message-ID: <20090227.171911.242321588.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F283B712F@orsmsx501.amr.corp.intel.com>
	<20090227.161011.220557653.davem@davemloft.net>
	<9929d2390902271702v19deb711v4d729b4cb7dad1e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, herbert@gondor.apana.org.au,
	emil.s.tantilov@intel.com, patrick.ohly@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60363
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752578AbZB1BTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 20:19:30 -0500
In-Reply-To: <9929d2390902271702v19deb711v4d729b4cb7dad1e6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 27 Feb 2009 17:02:48 -0800

> So the removal of the skb_orphan() in the driver should be a good
> thing, the only issue is with the patch description?  By cleaning up
> the patch description, will that make this patch acceptable for
> everyone?

Yes, that would work for me, thanks Jeff.
