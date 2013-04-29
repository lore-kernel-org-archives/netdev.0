From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: shows HW time stamping support only if
 ptp_capable is present
Date: Mon, 29 Apr 2013 15:16:58 -0400 (EDT)
Message-ID: <20130429.151658.1713298367183696606.davem@davemloft.net>
References: <1367255287-2664-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, nsujir@broadcom.com,
	mchan@broadcom.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758248Ab3D2TRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:17:03 -0400
In-Reply-To: <1367255287-2664-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Mon, 29 Apr 2013 14:08:07 -0300

> Current tg3 shows hardware timestamping support for all devices
> when that is true only for the hardware with PTP_CAPABLE flag
> present.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied.
