From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netpoll fix racy dev->flags usage
Date: Tue, 22 Mar 2005 18:40:59 -0800
Message-ID: <20050322184059.73bef4d5.davem@davemloft.net>
References: <20050310232245.GR3120@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kaber@trash.net
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050310232245.GR3120@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Mar 2005 15:22:46 -0800
Matt Mackall <mpm@selenic.com> wrote:

> Put ndev->flags usage under the lock. Spotted by Patrick McHardy.
> 
> Signed-off-by: Matt Mackall <mpm@selenic.com>

Applied, thanks Matt.
