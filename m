From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9][BNX2]: Move tx indexes into bnx2_napi struct.
Date: Thu, 20 Dec 2007 19:57:05 -0800 (PST)
Message-ID: <20071220.195705.03168169.davem@davemloft.net>
References: <1198182730.9163.30.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53471
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752360AbXLUD5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:57:06 -0500
In-Reply-To: <1198182730.9163.30.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:32:10 -0800

> [BNX2]: Move tx indexes into bnx2_napi struct.
> 
> Tx related fields used in NAPI polling are moved from the main
> bnx2 struct to the bnx2_napi struct.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
