From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AF_PACKET]: Allow multicast traffic to be caught by
 ORIGDEV when bonded
Date: Wed, 07 Nov 2007 03:52:06 -0800 (PST)
Message-ID: <20071107.035206.187180402.davem@davemloft.net>
References: <20071106152547.14672.10821.stgit@localhost.localdomain>
	<20071107.022116.16986000.davem@davemloft.net>
	<D5C1322C3E673F459512FB59E0DDC32903ED74CE@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43724
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753325AbXKGLwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 06:52:06 -0500
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903ED74CE@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Wed, 7 Nov 2007 03:00:42 -0800

> In any event, the only thing this could affect is if the option is
> set on the socket, which shouldn't be very often at all.

Any idea how many programs set this option and which
ones?  You obviously noticed, so perhaps you know at
least one or was this discovered purely by code
inspection?
