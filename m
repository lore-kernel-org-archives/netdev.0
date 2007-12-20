From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 5/9] SCTP: ADD-IP updates the states where
 ASCONFs can be sent
Date: Thu, 20 Dec 2007 14:11:18 -0800 (PST)
Message-ID: <20071220.141118.19133945.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-6-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37620
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753451AbXLTWLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:11:19 -0500
In-Reply-To: <1197927169-5106-6-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:45 -0500

>    C4)  Both ASCONF and ASCONF-ACK Chunks MUST NOT be sent in any SCTP
>         state except ESTABLISHED, SHUTDOWN-PENDING, SHUTDOWN-RECEIVED,
>         and SHUTDOWN-SENT.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
