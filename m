From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Formatting fix for /proc/net/fib_trie.
Date: Tue, 05 Feb 2008 02:58:57 -0800 (PST)
Message-ID: <20080205.025857.257438228.davem@davemloft.net>
References: <1202205536-9888-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756774AbYBEK63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 05:58:29 -0500
In-Reply-To: <1202205536-9888-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue,  5 Feb 2008 12:58:56 +0300

> The line in the /proc/net/fib_trie for route with TOS specified
> - has extra \n at the end
> - does not have a space after route scope
> like below.
>            |-- 1.1.1.1
>               /32 universe UNICASTtos =1
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
