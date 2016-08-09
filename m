From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 05/14] net: ethernet: ti: cpsw: don't check slave num
 in runtime
Date: Tue, 9 Aug 2016 13:46:49 +0530
Message-ID: <49e388d8-6151-1f29-19ad-6084abc4331b@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-6-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:39524 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725AbcHIIQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2016 04:16:55 -0400
In-Reply-To: <1470480524-6851-6-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 06 August 2016 04:18 PM, Ivan Khoronzhuk wrote:
> No need to check const slave num in runtime for every packet,
> and ndev for slaves w/o ndev is anyway NULL. So remove redundant
> check.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
