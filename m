From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/usb: kalmia: Various fixes for better support of
 non-x86 architectures.
Date: Wed, 22 Jun 2011 13:41:41 -0700 (PDT)
Message-ID: <20110622.134141.2038336105148103673.davem@davemloft.net>
References: <20110619.155755.1854488306547854947.davem@davemloft.net>
	<1308756376-9920-1-git-send-email-marius@kotsbak.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	marius@kotsbak.com
To: marius.kotsbak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181Ab1FVUlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2011 16:41:45 -0400
In-Reply-To: <1308756376-9920-1-git-send-email-marius@kotsbak.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Marius B. Kotsbak" <marius.kotsbak@gmail.com>
Date: Wed, 22 Jun 2011 17:26:16 +0200

> -Support for big endian.
> -Do not use USB buffers at the stack.
> -Safer/more efficient code for local constants.
> 
> Signed-off-by: Marius B. Kotsbak <marius@kotsbak.com>

Applied, thanks.
