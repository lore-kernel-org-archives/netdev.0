From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] [FS_ENET] TX stuff should use fep->tx_lock,	instead
 of fep->lock.
Date: Thu, 20 Sep 2007 00:18:24 -0400
Message-ID: <46F1F490.2040605@garzik.org>
References: <20070918160527.13525.80935.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vitaly Bordug <vitb@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42227 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbXITES1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 00:18:27 -0400
In-Reply-To: <20070918160527.13525.80935.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Bordug wrote:
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> 
> ---
> 
>  drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)

applied 1-2, after hand-editing the subject line to remove brackets from 
around "[FS_ENET]"

everything within [ and ] is removed, before copying to changelog, so 
please be careful

See http://linux.yyz.us/patch-format.html for more info.

	Jeff


