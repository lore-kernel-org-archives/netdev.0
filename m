From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6] igb: restrict WoL for 82576 ET2 Quad Port
 Server Adapter
Date: Thu, 01 Apr 2010 21:12:58 -0700
Message-ID: <1270181578.14388.25.camel@localhost.localdomain>
References: <4BB4D13C.8030303@redhat.com>
	 <20100401.193435.223373423.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "sassmann@redhat.com" <sassmann@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48976 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750714Ab0DBENA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 00:13:00 -0400
In-Reply-To: <20100401.193435.223373423.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-01 at 19:34 -0700, David Miller wrote:
> From: Stefan Assmann <sassmann@redhat.com>
> Date: Thu, 01 Apr 2010 19:00:44 +0200
> 
> > From: Stefan Assmann <sassmann@redhat.com>
> > 
> > Restrict Wake-on-LAN to first port on 82576 ET2 quad port NICs, as it is
> > only supported there.
> > 
> > Signed-off-by: Stefan Assmann <sassmann@redhat.com>
> 
> Intel folks I assume you will suck this in and resubmit to
> me?
> 
> Thanks.

Correct, I am sucking this in to my tree.
-- 
Cheers,
Jeff

