From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/4] 2.6.5-rc2 - epic100 update
Date: Mon, 22 Mar 2004 19:12:19 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405F80E3.1070602@pobox.com>
References: <20040320152109.A31118@electric-eye.fr.zoreil.com> <20040323005021.A1715@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040323005021.A1715@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Schedule:
> 
> - epic100-fixup.patch:   opportunistic cleanup
> - epic100-napi-00.patch: code shuffling before the move
> - epic100-napi-10.patch: rx napi (includes netif_running change)
> - epic100-napi-20.patch: minimalistic tx napi
> 
> 2.6.5-rc2 and 2.6.5-rc2-mm1 contain the same drivers/net/epic100.c
> so the patches should apply equally to both.
> 
> The driver has been moderately tested. 

Thanks.

Applied to my netdev-2.6 queue, and so it should automatically appear in 
Andrew's -mm tree soon.

	Jeff
