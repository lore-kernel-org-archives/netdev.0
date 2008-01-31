From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 01 Feb 2008 00:04:45 +0100
Message-ID: <47A2540D.8090003@gmail.com>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org> <47A230A8.7080100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:1110 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbYAaXAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 18:00:21 -0500
Received: by ug-out-1314.google.com with SMTP id z38so655340ugc.16
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 15:00:16 -0800 (PST)
In-Reply-To: <47A230A8.7080100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 01/31/2008 09:33 PM:

> Andi Kleen wrote, On 01/31/2008 08:34 PM

 ...

>> Basically you're suggesting that nearly everyone using tc should learn about
>> another obscure command

 
...On the other hand, with this DSL argument from the sub-thread you
could be quite right: if this "everyone" wants to use one NIC for
both high speed local network and such a DSL, then learning ethtool
could be not enough...

Jarek P.

