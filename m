From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Use TASK_COMM_LEN macro.
Date: Thu, 10 Feb 2005 19:51:45 -0800
Message-ID: <20050210195145.23f2b679.davem@davemloft.net>
References: <20050210.135916.65691686.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050210.135916.65691686.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2005 13:59:16 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Use TASK_COMM_LEN macro instead of magic number 16.
> 
> Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks a lot.
