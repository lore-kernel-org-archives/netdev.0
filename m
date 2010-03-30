From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v7 04/12] net-caif: add CAIF Link layer
 device header files
Date: Mon, 29 Mar 2010 17:11:08 -0700 (PDT)
Message-ID: <20100329.171108.98400982.davem@davemloft.net>
References: <1269900693-9118-3-git-send-email-sjur.brandeland@stericsson.com>
	<1269900693-9118-4-git-send-email-sjur.brandeland@stericsson.com>
	<1269900693-9118-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44488
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752504Ab0C3ALH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 20:11:07 -0400
In-Reply-To: <1269900693-9118-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Tue, 30 Mar 2010 00:11:25 +0200

> +#endif	/* CAIF_DEVICE_H_ */
> +

There are extra empty newlines at the end of several files
just like this here, GIT warns about this when I try to
apply your patches, therefore please fix this.

It happens in several files in several of your patch postings,
so please audit them all for this problem.
