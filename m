From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH RESEND] mwifiex: Remove custom world regulatory domain
Date: Mon, 30 Jun 2014 23:18:07 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430FE5F37532@SC-VEXCH1.marvell.com>
References: <1403963353-27317-1-git-send-email-mpa@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Markus Pargmann <mpa@pengutronix.de>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:20645 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751269AbaGAGSI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 02:18:08 -0400
In-Reply-To: <1403963353-27317-1-git-send-email-mpa@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Markus,

> Subject: [PATCH RESEND] mwifiex: Remove custom world regulatory domain

This patch has been merged to wireless-next already:
http://git.kernel.org/cgit/linux/kernel/git/linville/wireless-next.git/commit/?id=7d8831bb1bfbf8db896bfc1de9d0b3bc7a8e60f0

> 
> A custom regulatory domain was introduced in this commit:
> cc0ba0d522c4 (mwifiex: support custom world regulatory domain)
> 
> The commit description says that it was introduced because the world
> regulatory domain does not include channels 52-64 and 100-140. These
> channels are described in the world regulatory domain now, so we can drop
> this custom regulatory domain.
> 
> Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
> Acked-by: Bing Zhao <bzhao@marvell.com>

Regards,
Bing
