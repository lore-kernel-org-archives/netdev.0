From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 12/13] net: ethernet: ti: cpsw: move napi struct to
 cpsw_common
Date: Wed, 10 Aug 2016 21:17:20 +0530
Message-ID: <11396e4d-1a21-b77d-b9ba-31c00df9fbc8@ti.com>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470784964-26440-13-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-13-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 August 2016 04:52 AM, Ivan Khoronzhuk wrote:
> The napi structs are common for both net devices in dual_emac
> mode, In order to not hold duplicate links to them, move to
> cpsw_common.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
