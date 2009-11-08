From: David Miller <davem@davemloft.net>
Subject: Re: RFC: ethtool support for n-tuple filter programming
Date: Sat, 07 Nov 2009 20:27:12 -0800 (PST)
Message-ID: <20091107.202712.222562359.davem@davemloft.net>
References: <1257533841.2610.12.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbZKHE0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2009 23:26:47 -0500
In-Reply-To: <1257533841.2610.12.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Fri, 06 Nov 2009 10:57:21 -0800

> Any comments, thoughts, suggestions, or ideas are welcome.

We can use the existing datastructures and defines used for
ETHTOOL_GRX* for new ethtool commands that do filtering.

NIU can filter on these tuples too.
