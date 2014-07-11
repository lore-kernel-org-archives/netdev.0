From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 2/2] MAINTAINERS: add net/6lowpan/ maintainer entry
Date: Fri, 11 Jul 2014 13:24:45 +0200
Message-ID: <62A8D5D9-3E07-4256-B0AA-A20413A2CF37@holtmann.org>
References: <1405067059-18782-1-git-send-email-alex.aring@gmail.com> <1405067059-18782-3-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, jukka.rissanen@linux.intel.com,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-bluetooth@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:55407 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbaGKLYm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 07:24:42 -0400
In-Reply-To: <1405067059-18782-3-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

> This patch add a maintainer entry for "net/6lowpan". Also add the current
> IEEE 802.15.4 mailing list and bluetooth mailinglist to this branch,
> because this code is shared between them.
> 
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
> MAINTAINERS | 7 +++++++
> 1 file changed, 7 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5eede71..acad051 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -148,6 +148,13 @@ L:	linux-scsi@vger.kernel.org
> S:	Maintained
> F:	drivers/scsi/53c700*
> 
> +6LOWPAN GENERIC (BTLE/IEEE 802.15.4)
> +M:	Alexander Aring <alex.aring@gmail.com>
> +L:	linux-zigbee-devel@lists.sourceforge.net (moderated for non-subscribers)
> +L:	linux-bluetooth@vger.kernel.org
> +S:	Maintained
> +F:	net/6lowpan/
> +

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel
