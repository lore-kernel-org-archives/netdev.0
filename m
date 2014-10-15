From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/1] net: fec: ptp: fix convergence issue to support
 LinuxPTP stack
Date: Wed, 15 Oct 2014 15:25:43 +0200
Message-ID: <20141015132543.GA15339@netboy>
References: <1413365412-22072-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, b20596@freescale.com
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:55828 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaJONZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 09:25:49 -0400
Received: by mail-wg0-f42.google.com with SMTP id z12so1329553wgg.13
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 06:25:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1413365412-22072-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 05:30:12PM +0800, Fugang Duan wrote:
> Changes V2:
> Modify the commit/comments log to describe the issue clearly.

Thanks, it is more clear now.

Acked-by: Richard Cochran <richardcochran@gmail.com>
