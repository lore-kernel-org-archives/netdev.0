From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] Support for SCTP_RCVINFO ancillary data
Date: Wed, 18 Jun 2014 16:30:28 -0700 (PDT)
Message-ID: <20140618.163028.64645484433325569.davem@davemloft.net>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
	<1403017296-28469-3-git-send-email-geirola@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com
To: geirola@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbaFRXa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:30:29 -0400
In-Reply-To: <1403017296-28469-3-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geir Ola Vaagland <geirola@gmail.com>
Date: Tue, 17 Jun 2014 17:01:32 +0200

> +}
> +
> +
>  /* Copy out the sndrcvinfo into a msghdr.  */

One empty line only here, thanks.
