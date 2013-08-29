From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: no need to call ether_setup()
Date: Fri, 30 Aug 2013 00:29:06 +0400
Message-ID: <521FAF12.5070508@cogentembedded.com>
References: <201308300024.48415.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308300024.48415.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/30/2013 12:24 AM, Sergei Shtylyov wrote:

> There's no need to call ether_setup() in the driver since prior alloc_etherdev()
> call already arranges for it.

> Suggested-by: Denis Kirjanov <kda@linux-powerpc.org>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

> ---

   Sorry, forgot to mention the patch is against the 'net-next.git' repo. :-/

WBR, Sergei

