From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/11][TG3]: Clear GPIO mask before storing.
Date: Sat, 05 May 2007 11:51:53 -0700 (PDT)
Message-ID: <20070505.115153.106772744.davem@davemloft.net>
References: <1178326358.4859.19.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755062AbXEESwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 14:52:06 -0400
In-Reply-To: <1178326358.4859.19.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 17:52:38 -0700

> [TG3]: Clear GPIO mask before storing.
> 
> The GPIO settings may change during reset and so the stored values in
> tp->grc_local_ctrl should be cleared first.
> 
> Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
