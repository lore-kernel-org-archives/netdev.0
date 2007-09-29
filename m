From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/9] fs_enet: Whitespace cleanup.
Date: Sat, 29 Sep 2007 01:21:06 -0400
Message-ID: <46FDE0C2.5010207@pobox.com>
References: <20070920220116.GA28784@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57294 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743AbXI2FVI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:21:08 -0400
In-Reply-To: <20070920220116.GA28784@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Wood wrote:
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |   85 ++++++++++++++++-------------------
>  drivers/net/fs_enet/fs_enet.h      |    4 +-
>  drivers/net/fs_enet/mac-fcc.c      |    1 -
>  drivers/net/fs_enet/mii-bitbang.c  |    3 -
>  drivers/net/fs_enet/mii-fec.c      |    1 -
>  5 files changed, 41 insertions(+), 53 deletions(-)

ACK patches 1-2, 4-9

This patch doesn't apply cleanly to netdev-2.6.git#upstream (nor 
net-2.6.24.git), so this and the rest of the patch series failed to apply.

Please resend series on top of netdev-2.6.git#upstream or net-2.6.24.git.


