From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: fix to append hardware time stamping
 flags
Date: Tue, 30 Apr 2013 15:11:09 -0400 (EDT)
Message-ID: <20130430.151109.892452364355464510.davem@davemloft.net>
References: <1367342434-1946-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, nsujir@broadcom.com,
	mchan@broadcom.com, sergei.shtylyov@cogentembedded.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932711Ab3D3TLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:11:11 -0400
In-Reply-To: <1367342434-1946-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Tue, 30 Apr 2013 14:20:34 -0300

> The commit f233a976ad15c3b8c54c0157f3c41d23f7514279 (tg3: shows
> HW time stamping support only if ptp_capable is present) didn't
> append hardware flags correctly. This patch fixes it.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

Applied, thanks.
