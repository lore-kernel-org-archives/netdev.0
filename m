From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/packet/af_packet.c: make some code static
Date: Mon, 27 Dec 2004 19:09:20 -0800
Message-ID: <20041227190920.5ac1964f.davem@davemloft.net>
References: <20041215004745.GI23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215004745.GI23151@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 01:47:45 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below makes some needlessly global code static.

Looks good.  Applied, thanks Adrian.
