From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Copy mac_len in skb_clone() as well
Date: Thu, 15 Mar 2007 03:02:35 -0700 (PDT)
Message-ID: <20070315.030235.79052031.davem@davemloft.net>
References: <20070314130711.GA6812@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, devel@openvz.org
To: adobriyan@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752789AbXCOKCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 06:02:36 -0400
In-Reply-To: <20070314130711.GA6812@localhost.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@sw.ru>
Date: Wed, 14 Mar 2007 16:07:11 +0300

> ANK says: "It is rarely used, that's wy it was not noticed.
> But in the places, where it is used, it should be disaster."
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied.

What bug triggered that helped you discover this?  Or is it
merely from a code audit?

Thanks.
