From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000e: WoL does not work on 82577/82578
 with manageability enabled
Date: Sat, 15 Aug 2009 18:53:18 -0700 (PDT)
Message-ID: <20090815.185318.245088107.davem@davemloft.net>
References: <20090815003524.2335.3107.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53696
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752032AbZHPBxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 21:53:07 -0400
In-Reply-To: <20090815003524.2335.3107.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Aug 2009 17:35:33 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> With manageability (Intel AMT) enabled via BIOS, PHY wakeup does not get
> configured on newer parts which use PHY wakeup vs. MAC wakeup which causes
> WoL to not work.  The driver should configure PHY wakeup whether or not
> manageability is enabled.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
