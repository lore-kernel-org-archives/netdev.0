From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] tg3: Fix SEEPROM accesses
Date: Mon, 20 Apr 2009 14:53:28 -0700 (PDT)
Message-ID: <20090420.145328.227301985.davem@davemloft.net>
References: <1240247953.7009@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47946
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755106AbZDTVxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 17:53:37 -0400
In-Reply-To: <1240247953.7009@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:52:49 -0700

> The recent NVRAM patches sanitized how the driver deals with NVRAM
> data, but they failed to bring the SEEPROM interfaces inline with
> the new strategy.  This patch brings the SEEPROM interfaces up to date.
> This patch also reverts commit 0d489ffb76de0fe804cf06a9d4d11fa7342d74b9.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Tested-by: Robin Holt <holt@sgi.com>
> Tested-by: James Bottomley <james.bottomley@HansenPartnership.com>

Applied, thanks.

But please provide a text string header line from the commit message
of commits you reference by SHA1 ID, I think I've told you guys to
do this more than once.
