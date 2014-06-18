From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/6] Support for SCTP_RECVRCVINFO socket option
Date: Wed, 18 Jun 2014 16:30:03 -0700 (PDT)
Message-ID: <20140618.163003.1333759678831582150.davem@davemloft.net>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
	<1403017296-28469-2-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com
To: geirola@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756225AbaFRXaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:30:05 -0400
In-Reply-To: <1403017296-28469-2-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geir Ola Vaagland <geirola@gmail.com>
Date: Tue, 17 Jun 2014 17:01:31 +0200

> +}
> +
> +
> +
>  /* API 6.2 setsockopt(), getsockopt()

Please do not add more than one empty line between top-level objects
in the source file.


> +	return 0;
> +}
> +
> +
> +
>  static int sctp_getsockopt(struct sock *sk, int level, int optname,
>  			   char __user *optval, int __user *optlen)

Likewise.
