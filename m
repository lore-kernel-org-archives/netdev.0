From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/socket.c: make a function static
Date: Mon, 27 Dec 2004 18:52:56 -0800
Message-ID: <20041227185256.74f617f4.davem@davemloft.net>
References: <20041212211506.GY22324@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041212211506.GY22324@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Dec 2004 22:15:06 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below makes a needlessly global function static.

Applied, I think we used to use this for the compat layers.

Thanks Adrian.
