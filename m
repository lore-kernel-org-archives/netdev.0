From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Thu, 16 Jun 2016 00:05:45 -0500
Message-ID: <576233A9.7060807@codeaurora.org>
References: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
 <20160615.214142.1092705919839921659.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, f.fainelli@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33539 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbcFPFFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 01:05:50 -0400
In-Reply-To: <20160615.214142.1092705919839921659.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Please always order local variable declarations from longest to shortest
> line.
>
> Audit your entire driver for this issue, thanks.

I will fix this in v6.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
