From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 8/9] smc911x: test after postfix decrement fails in smc911x_{reset,drop_pkt}
Date: Fri, 25 Apr 2008 02:04:02 -0400
Message-ID: <48117452.8070003@garzik.org>
References: <200804182050.m3IKonMV014845@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 12o3l@tiscali.nl, jacmet@sunsite.dk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57190 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755871AbYDYGEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:04:05 -0400
In-Reply-To: <200804182050.m3IKonMV014845@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Roel Kluin <12o3l@tiscali.nl>
> 
> When timeout reaches 0 the postfix decrement still subtracts, so the test
> fails.
> 
> [akpm@linux-foundation.org: coding-style fixes]
> Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
> Acked-by: Peter Korsgaard <jacmet@sunsite.dk>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied


