From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: DCB generic netlink interface
Date: Wed, 11 Jun 2008 19:50:59 +0200
Message-ID: <48501083.2040006@trash.net>
References: <20080605.074324.38999631.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC3290538B840@orsmsx414.amr.corp.intel.com> <20080611175156.GR20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47740 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbYFKR4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 13:56:18 -0400
In-Reply-To: <20080611175156.GR20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> Another area of interest is sending congestion frames on our own. We
> could finally implement real ingress software shaping and turn every
> linux system into a DCB capable node.

There was a qdisc submission for a scheduler called "pace" (IIRC)
that did this. It needed some cleanups before merging, but nothing
grave.


