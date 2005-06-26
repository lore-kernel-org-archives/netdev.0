From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/hamradio/: cleanups
Date: Sun, 26 Jun 2005 18:26:49 -0400
Message-ID: <42BF2BA9.8060502@pobox.com>
References: <20050502014637.GQ3592@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050502014637.GQ3592@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the following cleanups:
> - dmascc.c: remove the unused global function dmascc_setup

Better to use it, then remove it.

	Jeff
