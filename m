From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: add/use RMCR.RNC bit
Date: Wed, 23 Oct 2013 02:16:46 +0400
Message-ID: <5266F94E.9030406@cogentembedded.com>
References: <201310160229.58735.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org,
	davem@davemloft.net, horms@verge.net.au
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201310160229.58735.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 10/16/2013 02:29 AM, Sergei Shtylyov wrote:

> Declare 'enum EMCR_BIT' containing the single member for the RMCR.RNC bit and

    Hm, looks like I typoed here, should have been RMCR_BIT. David, should I 
resubmit or you can fix it while applying? Or simply not worth the trouble?

> replace bare numbers in the driver by  this mnemonic.

> Suggested-by: David Miller <davem@davemloft.net>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---
> This patch is against DaveM's 'net.git' repo but it intended for 'net-next.git'
> repo -- it's  because 'net-next.git' doesn't contain the required Simon Horman's
> patch yet.

WBR, Sergei

