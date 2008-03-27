From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.25? 1/3] smc91x: fix build breakage from the SMC_GET_MAC_ADDR
 API upgrade
Date: Thu, 27 Mar 2008 08:22:56 -0400
Message-ID: <47EB91A0.8040902@garzik.org>
References: <200803270745.m2R7jAX2024160@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cooloney@kernel.org, dsaxena@plexity.net,
	lethal@linux-sh.org, nico@cam.org, rmk+kernel@arm.linux.org.uk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56862 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755709AbYC0MW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 08:22:59 -0400
In-Reply-To: <200803270745.m2R7jAX2024160@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Bryan Wu <cooloney@kernel.org>
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Deepak Saxena <dsaxena@plexity.net>
> Cc: Nicolas Pitre <nico@cam.org>
> Cc: Russell King <rmk+kernel@arm.linux.org.uk>
> Cc: Paul Mundt <lethal@linux-sh.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/smc91x.h |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

davem already has this


