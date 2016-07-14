From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] stmmac: dwmac-socfpga: remove redundant dev_err
 call in socfpga_dwmac_parse_data()
Date: Wed, 13 Jul 2016 18:08:25 -0700 (PDT)
Message-ID: <20160713.180825.16150764525787936.davem@davemloft.net>
References: <1468414000-2860-1-git-send-email-weiyj_lk@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: weiyj_lk@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbcGNBI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 21:08:26 -0400
In-Reply-To: <1468414000-2860-1-git-send-email-weiyj_lk@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: weiyj_lk@163.com
Date: Wed, 13 Jul 2016 12:46:40 +0000

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
