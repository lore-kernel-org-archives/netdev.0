From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7][TG3]: Allow partial speed advertisement.
Date: Thu, 07 Dec 2006 00:22:01 -0800 (PST)
Message-ID: <20061207.002201.78477572.davem@davemloft.net>
References: <1165477607.8488.30.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031846AbWLGIVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 03:21:49 -0500
To: mchan@broadcom.com
In-Reply-To: <1165477607.8488.30.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 06 Dec 2006 23:46:47 -0800

> [TG3]: Allow partial speed advertisement.
> 
> Honor the advertisement bitmask from ethtool.  We used to always
> advertise the full capability when autoneg was set to on.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

