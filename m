From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 04/14] net: ethernet: ti: cpsw: remove clk var from
 priv
Date: Tue, 9 Aug 2016 14:31:22 +0300
Message-ID: <c4238c4b-5b4b-94a8-86b5-51c63ea69698@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-5-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-5-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2016 01:48 PM, Ivan Khoronzhuk wrote:
> There is no need to hold link to clk, it's used only once
> while probe.
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>


-- 
regards,
-grygorii
