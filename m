From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/6] tg3: Move EEE definitions into mdio.h
Date: Mon, 06 Dec 2010 19:30:35 +0000
Message-ID: <1291663835.3443.4.camel@bwh-desktop>
References: <1291660134-3801-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13405 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab0LFTaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 14:30:39 -0500
In-Reply-To: <1291660134-3801-3-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-06 at 10:28 -0800, Matt Carlson wrote:
> In commit 52b02d04c801fff51ca49ad033210846d1713253 entitled "tg3: Add
> EEE support", Ben Hutchings had commented that the EEE advertisement
> register will be in a standard location.  This patch moves that
> definition into mdio.h and changes the code to use it.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Reviewed-by: Benjamin Li <benli@broadcom.com>
[...]

Thanks, Matt.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

