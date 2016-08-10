From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 07/13] net: ethernet: ti: cpsw: replace pdev on dev
Date: Wed, 10 Aug 2016 21:12:32 +0530
Message-ID: <3ed5825e-7bbf-5b69-8d93-775e78e5109a@ti.com>
References: <1470784964-26440-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470784964-26440-8-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470784964-26440-8-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 August 2016 04:52 AM, Ivan Khoronzhuk wrote:
> No need to hold pdev link when only dev is needed.
> This allows to simplify a bunch of cpsw->pdev->dev now and farther.
> 
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
