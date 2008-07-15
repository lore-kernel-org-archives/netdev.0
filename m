From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RFC 02/02]: netdrv intel: always enable VLAN filtering
 except in promiscous mode
Date: Tue, 15 Jul 2008 17:51:46 +0200
Message-ID: <487CC792.7070702@trash.net>
References: <487C9CD5.1050600@trash.net> <487C9CFC.5090101@trash.net> <D5C1322C3E673F459512FB59E0DDC329056ACA44@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61058 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbYGOPvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 11:51:50 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329056ACA44@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
> Patrick,
> 	What about ixgbe?  The patches look fine to me though.

Thanks. I missed ixgbe, I'll add it to the patch and resubmit.
