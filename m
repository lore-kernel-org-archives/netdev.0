From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/key/af_key.c: make pfkey_table static
Date: Mon, 27 Dec 2004 19:05:50 -0800
Message-ID: <20041227190550.165862d0.davem@davemloft.net>
References: <20041215004254.GG23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215004254.GG23151@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 01:42:54 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below makes the needlessly global pfkey_table static.

Applied, thanks Adrian.
