From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] net/socket.c : remove redundant NULL pointer check
 before kfree()
Date: Tue, 22 Mar 2005 18:47:50 -0800
Message-ID: <20050322184750.4ec7a51c.davem@davemloft.net>
References: <Pine.LNX.4.62.0503172028030.2512@dragon.hyggekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, obz@Kodak.COM, bir7@leland.Stanford.Edu,
        waltje@uWalt.NL.Mugnet.ORG, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.62.0503172028030.2512@dragon.hyggekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 17 Mar 2005 20:34:05 +0100 (CET)
Jesper Juhl <juhl-lkml@dif.dk> wrote:

> kfree() handles NULL pointers just fine, checking first is pointless.
> 
> Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>

Applied, thanks Jesper.
