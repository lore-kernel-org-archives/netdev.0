From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9][TG3]: Add tg3_poll_fw().
Date: Wed, 27 Sep 2006 16:03:40 -0700 (PDT)
Message-ID: <20060927.160340.95062228.davem@davemloft.net>
References: <1159389289.3411.22.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28326
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031207AbWI0XDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 19:03:41 -0400
To: mchan@broadcom.com
In-Reply-To: <1159389289.3411.22.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 27 Sep 2006 13:34:49 -0700

> [TG3]: Add tg3_poll_fw().
> 
> Put the firmware polling logic into a separate function.  This makes
> the code cleaner.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
