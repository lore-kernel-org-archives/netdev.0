From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/inetpeer.c: make a struct static
Date: Wed, 16 Mar 2005 14:53:43 -0800
Message-ID: <20050316145343.6e31ba6a.davem@davemloft.net>
References: <20050315144408.GL3189@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050315144408.GL3189@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 15:44:08 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> This patch makes a needlessly global struct static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

You need to also kill the externs in net/inetpeer.h

Please fix this up and resubmit.

Thanks Adrian.
