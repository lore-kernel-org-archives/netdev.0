From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: report correct hardware stamping info to
 ethtool
Date: Sun, 6 Jan 2013 09:15:14 +0100
Message-ID: <20130106081513.GB2276@netboy.at.omicron.at>
References: <1357436318-12425-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.or, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:55803 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab3AFIPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2013 03:15:25 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so8679213eek.39
        for <netdev@vger.kernel.org>; Sun, 06 Jan 2013 00:15:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357436318-12425-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank,

This also should be fixed in v3.8, but the fix will look
different. Would you please submit a patch for that, too?

BTW, you should always label the patch to tell which tree it goes
into, either "net" or "net-next". This patch is for net-next, but a
fix for v3.8 would be for net.

Thanks,
Richard
