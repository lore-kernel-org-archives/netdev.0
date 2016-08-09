From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH v2 01/14] net: ethernet: ti: cpsw: simplify submit routine
Date: Tue, 9 Aug 2016 14:27:42 +0300
Message-ID: <ec6a7031-ec03-096d-742a-6bc6ad8fa9eb@ti.com>
References: <1470480524-6851-1-git-send-email-ivan.khoronzhuk@linaro.org>
 <1470480524-6851-2-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<dlide@ti.com>
To: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	<netdev@vger.kernel.org>, <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470480524-6851-2-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/06/2016 01:48 PM, Ivan Khoronzhuk wrote:
> As second net dev is created only in case of dual_emac mode, port
> number can be figured out in simpler way. Also no need to pass
> redundant ndev struct.
>
> Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> ---

Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>


-- 
regards,
-grygorii
