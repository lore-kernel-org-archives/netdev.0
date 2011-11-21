From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Change mii to ethtool advertisement function names
Date: Mon, 21 Nov 2011 15:27:47 -0500 (EST)
Message-ID: <20111121.152747.863067470156149043.davem@davemloft.net>
References: <1321576255-29827-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40582 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095Ab1KUU2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:28:04 -0500
In-Reply-To: <1321576255-29827-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 17 Nov 2011 16:30:55 -0800

> This patch implements advice by Ben Hutchings to change the mii side of
> the function names to look more like the register whose values they
> convert.  New LPA translation functions have been added as well.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.

Please use appropriate subject prefixes in the future, I fixed this one
up to use "net: ".

Thanks.
