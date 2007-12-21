From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9][BNX2]: Move rx indexes into bnx2_napi struct.
Date: Thu, 20 Dec 2007 19:57:26 -0800 (PST)
Message-ID: <20071220.195726.200538224.davem@davemloft.net>
References: <1198182745.9163.31.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53475
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753568AbXLUD51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 22:57:27 -0500
In-Reply-To: <1198182745.9163.31.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 20 Dec 2007 12:32:25 -0800

> [BNX2]: Move rx indexes into bnx2_napi struct.
> 
> Rx related fields used in NAPI polling are moved from the main
> bnx2 struct to the bnx2_napi struct.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
