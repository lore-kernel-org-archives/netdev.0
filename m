From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/13] bnx2x: Use VPD-R V0 entry to display firmware
 revision
Date: Sun, 18 Apr 2010 21:00:22 -0700 (PDT)
Message-ID: <20100418.210022.226782192.davem@davemloft.net>
References: <1271602093.27235.179.camel@lb-tlvb-vladz>
	<1271603308.3679.208.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladz@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	dmitry@broadcom.com, mcarlson@broadcom.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750766Ab0DSEAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 00:00:18 -0400
In-Reply-To: <1271603308.3679.208.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Sun, 18 Apr 2010 16:08:28 +0100

> On Sun, 2010-04-18 at 17:48 +0300, Vladislav Zolotarov wrote:
>> Use VPD-R V0 entry to display firmware revision
> [...]
> 
> Matt Carlson already added VPD support functions and definitions to the
> PCI core; you should use them.

Agreed.

Really disappointed that you guy's can't keep track of generic
infrastructure created by co-workers let alone other people
in the networking developer community.

Judging by this and the LRO disabling change, I can only
come to the conclusion that you do development in something
similar to a bubble and are impervious to what's going on
outside of your domain :-)
