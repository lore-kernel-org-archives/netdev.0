From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] drivers/net/hamradio/: cleanups
Date: Sun, 26 Jun 2005 19:00:13 -0400
Message-ID: <42BF337D.1050904@pobox.com>
References: <20050502014637.GQ3592@stusta.de>	<42BF2BA9.8060502@pobox.com> <20050626155318.7f065d5b.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, akpm@osdl.org, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: randy_dunlap <rdunlap@xenotime.net>
In-Reply-To: <20050626155318.7f065d5b.rdunlap@xenotime.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

randy_dunlap wrote:
> On Sun, 26 Jun 2005 18:26:49 -0400 Jeff Garzik wrote:
> 
> | Adrian Bunk wrote:
> | > This patch contains the following cleanups:
> | > - dmascc.c: remove the unused global function dmascc_setup
> | 
> | Better to use it, then remove it.
> 
>                     than ??

Yes.  Use it via __setup() or similar.

	Jeff
