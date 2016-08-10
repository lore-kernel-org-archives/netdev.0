From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 11/13] net: ethernet: ti: cpsw: move platform data and
 slaves info to cpsw_common
Date: Wed, 10 Aug 2016 21:16:33 +0530
Message-ID: <6b2851dc-d4e7-500c-2409-ad7399dd200c@ti.com>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470784964-26440-12-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-12-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 August 2016 04:52 AM, Ivan Khoronzhuk wrote:
> These data are common for net devs in dual_emac mode. No need to hold
> it for every priv instance, so move them under cpsw_common.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
