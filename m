From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] netdev: remove unused S2IO_NAPI
Date: Sun, 06 Jul 2008 21:52:51 -0400
Message-ID: <487176F3.1030707@garzik.org>
References: <20080704125446.GA30300@havoc.gtf.org> <20080705.211029.199316974.davem@davemloft.net> <20080705.212051.82650078.davem@davemloft.net> <20080706214109.GA13120@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37065 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187AbYGGBw4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jul 2008 21:52:56 -0400
In-Reply-To: <20080706214109.GA13120@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  Documentation/networking/s2io.txt      |    7 ++-----
>  arch/ia64/configs/sn2_defconfig        |    1 -
>  arch/mips/configs/mtx1_defconfig       |    1 -
>  arch/powerpc/configs/pseries_defconfig |    1 -
>  arch/x86/configs/x86_64_defconfig      |    1 -
>  drivers/net/Kconfig                    |   14 --------------
>  6 files changed, 2 insertions(+), 23 deletions(-)

patches 1-3,

Acked-by: Jeff Garzik <jgarzik@redhat.com>

(davem said he wanted to go ahead and apply to his tree)


