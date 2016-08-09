From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v2 01/14] net: ethernet: ti: cpsw: simplify submit routine
Date: Tue, 9 Aug 2016 13:39:56 +0530
Message-ID: <8075c93f-09ef-709a-c39e-dc3ad9b7993e@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-2-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-2-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 06 August 2016 04:18 PM, Ivan Khoronzhuk wrote:
> As second net dev is created only in case of dual_emac mode, port
> number can be figured out in simpler way. Also no need to pass
> redundant ndev struct.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
