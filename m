From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] i4l: change magic numbers in Eicon DIVA ISDN
 driver to symbolic names
Date: Mon, 15 Mar 2010 15:48:48 -0700 (PDT)
Message-ID: <20100315.154848.112188183.davem@davemloft.net>
References: <201003112207.o2BM7PlG013464@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org, imunsie@au.ibm.com,
	mac@melware.de, sgayda2@uiuc.edu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34517
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937035Ab0COWs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 18:48:26 -0400
In-Reply-To: <201003112207.o2BM7PlG013464@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 11 Mar 2010 14:07:25 -0800

> From: Ian Munsie <imunsie@au.ibm.com>
> 
> Replace references to the '20' magic number found throughout the Eicon
> ISDN driver for the length of the station_id field in the T30_INFO struct
> with the T30_MAX_STATION_ID_LENGTH symbolic constant.
> 
> Signed-off-by: Ian Munsie <imunsie@au.ibm.com>
> Cc: Armin Schindler <mac@melware.de>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: Stoyan Gaydarov <sgayda2@uiuc.edu>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
