From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/8] tg3: Handle NVRAM absent cases
Date: Tue, 21 Apr 2009 01:41:51 -0700 (PDT)
Message-ID: <20090421.014151.239447870.davem@davemloft.net>
References: <1240247956.7015@xw6200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com,
	andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54721
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbZDUIl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:41:59 -0400
In-Reply-To: <1240247956.7015@xw6200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Mon, 20 Apr 2009 09:57:14 -0700

> Some 57780 ASIC revision parts do not have NVRAM.  Code the driver so
> that it is tolerant of this configuration.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
