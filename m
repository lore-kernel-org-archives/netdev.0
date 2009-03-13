From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] sctp: clean-ups and fixes
Date: Fri, 13 Mar 2009 11:40:03 -0700 (PDT)
Message-ID: <20090313.114003.217505594.davem@davemloft.net>
References: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59853
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753509AbZCMSkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 14:40:17 -0400
In-Reply-To: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 12 Mar 2009 15:49:16 -0400

> Hi David
> 
> This a small set of fixes in sctp:
>  1) clean up and simplify sctp listening code.
>  2) fix ASCONF indication in INIT-ACK.
>  3) send FORWARD TSN chunks only when peer supports the extension.
>  4) include Adaptation Indication parameter only when user set it.

All applied, thanks!
