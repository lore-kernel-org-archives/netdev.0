From: George Cherian <george.cherian@ti.com>
Subject: Re: [PATCH v2 0/3]  TI CPSW Cleanup
Date: Tue, 6 May 2014 17:33:22 +0530
Message-ID: <5368CF8A.2060808@ti.com>
References: <1399264035-22530-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>, <balbi@ti.com>, <zonque@gmail.com>,
	<mpa@pengutronix.de>, <bhutchings@solarflare.com>,
	<tklauser@distanz.ch>, <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399264035-22530-1-git-send-email-george.cherian@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,
On 5/5/2014 9:57 AM, George Cherian wrote:
> This series does some minimal cleanups.
> 	-Conversion of pr_*() to dev_*()
> 	-Convert kzalloc to devm_kzalloc.
>
> No functional changes.
>
> v1 -> v2 Address review comments.
>
> George Cherian (3):
>    driver net: cpsw: Convert pr_*() to dev_*() calls
>    net: davinci_mdio: Convert pr_err() to dev_err() call
>    drivers: net: davinci_cpdma: Convert kzalloc() to devm_kzalloc().
>
>   drivers/net/ethernet/ti/cpsw.c          | 50 ++++++++++++++++-----------------
>   drivers/net/ethernet/ti/davinci_cpdma.c | 35 ++++++++---------------
>   drivers/net/ethernet/ti/davinci_mdio.c  |  8 ++----
>   3 files changed, 39 insertions(+), 54 deletions(-)
For some reason i cant see this series in netdev patchwork.
Did I miss something?  If not can you please take this series.


-- 
-George
