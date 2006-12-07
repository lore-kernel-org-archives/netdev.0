From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/7][TG3]: Add TG3_FLG2_IS_NIC flag.
Date: Thu, 07 Dec 2006 00:21:27 -0800 (PST)
Message-ID: <20061207.002127.133270961.davem@davemloft.net>
References: <1165477589.8488.29.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42636
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031840AbWLGIVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 03:21:15 -0500
To: mchan@broadcom.com
In-Reply-To: <1165477589.8488.29.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 06 Dec 2006 23:46:29 -0800

> [TG3]: Add TG3_FLG2_IS_NIC flag.
> 
> Add Tg3_FLG2_IS_NIC flag to unambiguously determine whether the
> device is NIC or onboard.  Previously, the EEPROM_WRITE_PROT flag was
> overloaded to also mean onboard.  With the separation, we can
> support some devices that are onboard but do not use eeprom write
> protect.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
