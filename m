From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver skb recycling
Date: Mon, 29 Sep 2008 13:21:05 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52064B198F@orsmsx418.amr.corp.intel.com>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru> <20080928215035.GG19070@xi.wantstofly.org> <20080929053931.GB21663@2ka.mipt.ru> <20080929094650.GA26097@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <Ram.Natarajan@Emulex.Com>,
	"Eric Dumazet" <dada1@cosmosbay.com>,
	"Ashish Karkare" <akarkare@marvell.com>,
	"Nicolas Pitre" <nico@cam.org>
To: "Lennert Buytenhek" <buytenh@wantstofly.org>,
	"Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:24354 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752050AbYI2UVJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 16:21:09 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080929094650.GA26097@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> Could you (or anyone else) try this patch on one of your boxes and
> see what kind of effect it has on performance?

Lennert, we're very interested in this kind of work, and I'll see what
we can come up with by porting ixgbe or igb to use the patch.  Bad news
is it may be as far away as a couple of weeks, because of this e1000e
corrupt NVM thing I'm working on.

