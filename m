From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] remove unused net/sunrpc/svcauth_des.c
Date: Mon, 27 Dec 2004 18:45:05 -0800
Message-ID: <20041227184505.13d026a6.davem@davemloft.net>
References: <20041212194903.GG22324@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041212194903.GG22324@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 12 Dec 2004 20:49:03 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> I wasn't able to find any usage of this file.

Neither can I, and it doesn't even implement the auth_ops.
Applied, thanks Adrian.
