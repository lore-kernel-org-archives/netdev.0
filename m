From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 6/9] ipv4: ipmr: remove net pointer from struct
 mfc_cache
Date: Tue, 13 Apr 2010 04:10:36 -0700 (PDT)
Message-ID: <20100413.041036.266097612.davem@davemloft.net>
References: <1271007435-20035-1-git-send-email-kaber@trash.net>
	<1271007435-20035-7-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753020Ab0DMLKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 07:10:32 -0400
In-Reply-To: <1271007435-20035-7-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Sun, 11 Apr 2010 19:37:12 +0200

> From: Patrick McHardy <kaber@trash.net>
> 
> Now that cache entries in unres_queue don't need to be distinguished by their
> network namespace pointer anymore, we can remove it from struct mfc_cache
> add pass the namespace as function argument to the functions that need it.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This is ok.
