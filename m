From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 4/5] net: ethernet: ti: davinci_cpdma: move cpdma
 channel struct macroses to internals
Date: Wed, 17 Aug 2016 11:53:24 +0530
Message-ID: <18d62dfd-8e70-bc81-5b94-29612cdab82d@ti.com>
References: <1471303549-4134-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1471303549-4134-5-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	<nsekhar@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471303549-4134-5-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 16 August 2016 04:55 AM, Ivan Khoronzhuk wrote:
> Keep the driver internals in C file. Currently it's not required for
> drivers to know rx or tx a channel is, except create function.
> So correct "channel create" function, and use all channel struct
> macroses only for internal use.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
