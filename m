From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] tg3: Fix a flags typo
Date: Mon, 09 Jun 2008 15:42:43 -0700 (PDT)
Message-ID: <20080609.154243.221128280.davem@davemloft.net>
References: <1213046683.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763550AbYFIWmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 18:42:43 -0400
In-Reply-To: <1213046683.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 9 Jun 2008 11:25:55 -0700

> This patch fixes a problem where the TG3_FLAG_10_100_ONLY flag was
> testing against the wrong flags variable.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
