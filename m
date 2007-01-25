From: David Miller <davem@davemloft.net>
Subject: Re: [BNX2]: Fix 2nd port's MAC address.
Date: Thu, 25 Jan 2007 15:50:28 -0800 (PST)
Message-ID: <20070125.155028.108742256.davem@davemloft.net>
References: <1169703345.5442.4.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030528AbXAYXu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 18:50:29 -0500
In-Reply-To: <1169703345.5442.4.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 24 Jan 2007 21:35:45 -0800

> [BNX2]: Fix 2nd port's MAC address.
> 
> On the 5709, we need to add the proper offset to calculate the shared
> memory base address of the 2nd port correctly.  Otherwise, the 2nd
> port's MAC address and other information will be the same as the 1st
> port.
> 
> Update version to 1.5.4.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
