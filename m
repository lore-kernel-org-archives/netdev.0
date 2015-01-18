From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 1/7] net: wireless: wcn36xx: add wcn3620 chip type definition
Date: Sun, 18 Jan 2015 16:17:54 +0200
Message-ID: <878uh06ulp.fsf@kamboji.qca.qualcomm.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051043.31866.53087.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
	wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47984 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbbAROSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 09:18:01 -0500
In-Reply-To: <20150118051043.31866.53087.stgit@114-36-241-182.dynamic.hinet.net>
	(Andy Green's message of "Sun, 18 Jan 2015 13:10:43 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Green <andy.green@linaro.org> writes:

> Convert the list of chip types to an enum, add the default
> UNKNOWN type and a type for WCN3620 chip
>
> Signed-off-by: Andy Green <andy.green@linaro.org>

Please just use "wcn36xx: ", you should drop "net: wireless: " entirely.

-- 
Kalle Valo
