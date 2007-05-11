From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6 RESEND] Add support for the Davicom DM9161A PHY
Date: Fri, 11 May 2007 16:59:06 -0400
Message-ID: <4644D91A.2000704@garzik.org>
References: <20070510151604.6d8c58b4.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42385 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760572AbXEKU7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 May 2007 16:59:09 -0400
In-Reply-To: <20070510151604.6d8c58b4.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kim Phillips wrote:
> Distinguish between the Davicom DM9161A PHY and the DM9161E.
> 
> Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
> ---
> resend of the one of six in the series Jeff didn't receive.

note that when there is a problem, I drop the entire patch series.  This 
is ALWAYS how it's been done in Linux...  Thus, I only received patches 
1 and 2.


>  drivers/net/phy/davicom.c |   34 ++++++++++++++++++++++++++--------
>  1 files changed, 26 insertions(+), 8 deletions(-)

applied


