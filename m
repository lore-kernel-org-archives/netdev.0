From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] kill xfrm_export.c
Date: Tue, 8 Feb 2005 16:48:57 -0800
Message-ID: <20050208164857.1c51656e.davem@davemloft.net>
References: <20050119091715.GQ1841@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050119091715.GQ1841@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 19 Jan 2005 10:17:15 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> This patch removes xfrm_export.c and moves the EXPORT_SYMBOL{,_GPL}'s to 
> the files where the actual functions are.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
