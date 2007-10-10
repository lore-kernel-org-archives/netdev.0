From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3][BNX2]: Fix default WoL setting.
Date: Wed, 10 Oct 2007 16:16:59 -0700 (PDT)
Message-ID: <20071010.161659.45092794.davem@davemloft.net>
References: <1192060919.6534.5.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mann@vmware.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60267
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752820AbXJJXQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 19:16:56 -0400
In-Reply-To: <1192060919.6534.5.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 10 Oct 2007 17:01:59 -0700

> [BNX2]: Fix default WoL setting.
> 
> Change the default WoL setting to match the NVRAM's setting.  It
> always defaulted to WoL disabled before and caused a lot of confusion
> for users.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
