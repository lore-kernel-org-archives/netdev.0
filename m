From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next 0/8] cleanup for AMD811E ethernet driver
Date: Fri, 11 Jul 2014 15:18:04 +0530
Message-ID: <53BFB2D4.80004@gmail.com>
References: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: varkabhadram@gmail.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405064110-22579-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On 07/11/2014 01:05 PM, varkabhadram@gmail.com wrote:
> From: Varka Bhadram <varkab@cdac.in>
>
> This series cleanup for AMD811E ethernet driver
>
> Varka Bhadram (8):
>    ethernet: amd: move amd111e_remove_one after probe
>    ethernet: amd: use devm_ioremap()
>    ethernet: amd: dynamic debug fixes
>    ethernet: amd: fix comment styles
>    ethernet: amd: move pci device ids
>    ethernet: amd: fix 'foo* bar'
>    ethernet: amd: fix spaces and few coding styles
>    ethernet: amd: switch case fixes
>
>   drivers/net/ethernet/amd/amd8111e.c |  993 +++++++++++++++++------------------
>   1 file changed, 484 insertions(+), 509 deletions(-)
>
Please drop this series. I am getting checkpatch.pl errors.

I will fix it send it as 'v2'.
-- 
Regards,
Varka Bhadram.
