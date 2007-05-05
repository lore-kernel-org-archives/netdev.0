From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/11][TG3]: WoL fixes.
Date: Sat, 05 May 2007 11:52:29 -0700 (PDT)
Message-ID: <20070505.115229.51520594.davem@davemloft.net>
References: <1178326364.4859.20.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53293
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755080AbXEESwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 14:52:42 -0400
In-Reply-To: <1178326364.4859.20.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 17:52:44 -0700

> [TG3]: WoL fixes.
> 
> Change TG3_FLAG_SERDES_WOL_CAP to TG3_FLAG_WOL_CAP to make it easier
> to manage WoL.  This flag is now used consistently during ethtool WoL
> setup and power setting changes.
> 
> Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks!
