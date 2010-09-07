From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: discard overlapping fragment
Date: Mon, 06 Sep 2010 18:11:22 -0700 (PDT)
Message-ID: <20100906.181122.245409564.davem@davemloft.net>
References: <4C811081.3030500@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53912
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752770Ab0IGBLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:11:05 -0400
In-Reply-To: <4C811081.3030500@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 03 Sep 2010 17:13:05 +0200

> here is a patch to take care of RFC5722 "Handling of Overlapping IPv6
> Fragments" in IPv6 stack.

Applied to net-2.6
