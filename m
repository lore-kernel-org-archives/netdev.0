From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2]: VLAN filtering fixes
Date: Wed, 16 Jul 2008 20:16:33 -0700 (PDT)
Message-ID: <20080716.201633.51238134.davem@davemloft.net>
References: <487DC2C4.9030006@trash.net>
	<9929d2390807161403g6db1247due0a209a088846a89@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jgarzik@pobox.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41710
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753542AbYGQDQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 23:16:34 -0400
In-Reply-To: <9929d2390807161403g6db1247due0a209a088846a89@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Date: Wed, 16 Jul 2008 14:03:33 -0700

> On Wed, Jul 16, 2008 at 2:43 AM, Patrick McHardy <kaber@trash.net> wrote:
> > These two patches contain the last bits of my VLAN + tcpdump fixes.
> > Currently some (all?) drivers have inconsistent behaviour wrt. VLAN
> > filtering and promiscous mode:
 ...
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

I've applied Patrick's patches, thanks everyone.
