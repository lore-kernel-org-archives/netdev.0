From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] fs_enet: fix checkpatch.pl problems
Date: Tue, 17 Jun 2008 23:54:01 -0400
Message-ID: <485886D9.5070800@garzik.org>
References: <1213743794-3537-1-git-send-email-jrigby@freescale.com> <1213743794-3537-2-git-send-email-jrigby@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org
To: John Rigby <jrigby@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34489 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757966AbYFRDyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:54:16 -0400
In-Reply-To: <1213743794-3537-2-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Rigby wrote:
> Fixed all errors and warnings that checkpatch.pl
> reports if this was a new submission.
> Also changed instances of fec_t to struct fec in
> mac-fec.c and mii-fec.c.
> 
> This is in preparation of adding MPC5121 support.
> 
> Signed-off-by: John Rigby <jrigby@freescale.com>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |   70 ++++++++++++++++++++---------------
>  drivers/net/fs_enet/fs_enet.h      |   15 +++++---
>  drivers/net/fs_enet/mac-fcc.c      |    7 ++--
>  drivers/net/fs_enet/mac-fec.c      |   40 ++++++++++----------
>  drivers/net/fs_enet/mac-scc.c      |   13 ++++---
>  drivers/net/fs_enet/mii-bitbang.c  |    4 +-
>  drivers/net/fs_enet/mii-fec.c      |   23 +++++++-----
>  7 files changed, 95 insertions(+), 77 deletions(-)

patch does not apply


