From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NET] NEIGHBOUR: hold refcnt of net_device from proxy
 neighbor entries.
Date: Fri, 1 Oct 2004 15:17:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001151732.60899c38.davem@davemloft.net>
References: <20040930.170729.51800585.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040930.170729.51800585.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 17:07:29 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> [NET] NEIGHBOUR: hold refcnt of net_device from proxy neighbor entries.
>  
> We did not hold refcnt of net_device from proxy neighbor entries
> while we did from neighbor entries.
>  
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks.
