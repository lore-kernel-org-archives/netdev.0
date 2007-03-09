From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] udp: deinline
Date: Thu, 08 Mar 2007 20:46:49 -0800 (PST)
Message-ID: <20070308.204649.52164761.davem@davemloft.net>
References: <20070308205214.580772044@linux-foundation.org>
	<20070308205306.296232086@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46797
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992967AbXCIEqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 23:46:49 -0500
In-Reply-To: <20070308205306.296232086@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 08 Mar 2007 12:52:22 -0800

> A couple of functions are exported or used indirectly
> so it is pointless to mark them as inline.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied.
