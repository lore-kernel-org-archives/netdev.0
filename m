From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 09/13] bonding needs inet
Date: Tue, 22 Mar 2005 17:46:09 -0500
Message-ID: <4240A031.9050909@pobox.com>
References: <200503152222.j2FMMfU6016817@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: akpm@osdl.org
In-Reply-To: <200503152222.j2FMMfU6016817@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> The bonding driver needs CONFIG_INET, for arp_create(), arp_send(), arp_xmit().
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  25-akpm/drivers/net/Kconfig |    1 +
>  1 files changed, 1 insertion(+)
> 
> diff -puN drivers/net/Kconfig~bonding-needs-inet drivers/net/Kconfig
> --- 25/drivers/net/Kconfig~bonding-needs-inet	Tue Mar 15 14:19:54 2005
> +++ 25-akpm/drivers/net/Kconfig	Tue Mar 15 14:19:54 2005

applied
