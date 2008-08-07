From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/3] gianfar: Magic Packet and suspend/resume support.
Date: Thu, 07 Aug 2008 03:58:54 -0400
Message-ID: <489AAB3E.8020507@pobox.com>
References: <20080625215119.GB11784@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47890 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbYHGH7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 03:59:03 -0400
In-Reply-To: <20080625215119.GB11784@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  Documentation/powerpc/booting-without-of.txt |    5 +-
>  arch/powerpc/sysdev/fsl_soc.c                |    3 +
>  drivers/net/gianfar.c                        |  118 +++++++++++++++++++++++++-
>  drivers/net/gianfar.h                        |   12 ++-
>  drivers/net/gianfar_ethtool.c                |   41 +++++++++-
>  include/linux/fsl_devices.h                  |    1 +
>  6 files changed, 172 insertions(+), 8 deletions(-)

did this ever get ack'd by Kumar?  I don't have a record of it.


