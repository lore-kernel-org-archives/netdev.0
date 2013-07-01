From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3 2/3] sh_eth: add support RMIIMODE register
Date: Mon, 01 Jul 2013 18:27:16 +0400
Message-ID: <51D191C4.1030103@cogentembedded.com>
References: <1372652695-16606-1-git-send-email-horms+renesas@verge.net.au> <1372652695-16606-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1372652695-16606-3-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01-07-2013 8:24, Simon Horman wrote:

> This change is motivated by the lager board which uses the r8a7790 SoC,
> an R-Car SoC. For this board setting the RMIIMODE register is necessary.

> This patch assumes this is valid for all R-Car SoCs.

    This is not so for this version of the patch.

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

WBR, Sergei

