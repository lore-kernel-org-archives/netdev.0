From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Add phylib dependency to kconfig
Date: Thu, 29 May 2008 01:44:18 -0700 (PDT)
Message-ID: <20080529.014418.122219964.davem@davemloft.net>
References: <20080527180742.GB31979@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45191
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752837AbYE2IoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 04:44:22 -0400
In-Reply-To: <20080527180742.GB31979@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 27 May 2008 11:07:42 -0700

> This patch adds the PHYLIB dependency to kconfig.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>

I've merged this into patch 4/8 of the original set
and will push this into my tree shortly.
