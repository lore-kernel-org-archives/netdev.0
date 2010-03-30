From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 v7 04/12] net-caif: add CAIF Link layer
 device header files
Date: Mon, 29 Mar 2010 18:29:27 -0700
Message-ID: <1269912567.11714.223.camel@localhost.localdomain>
References: <1269900693-9118-3-git-send-email-sjur.brandeland@stericsson.com>
	 <1269900693-9118-4-git-send-email-sjur.brandeland@stericsson.com>
	 <1269900693-9118-5-git-send-email-sjur.brandeland@stericsson.com>
	 <20100329.171108.98400982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39830 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab0C3B3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 21:29:33 -0400
In-Reply-To: <20100329.171108.98400982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > +#endif	/* CAIF_DEVICE_H_ */
> > +
> 
> There are extra empty newlines at the end of several files
> just like this here, GIT warns about this when I try to
> apply your patches, therefore please fix this.
> 
> It happens in several files in several of your patch postings,
> so please audit them all for this problem.

some editors tend to do this for no reason. I don't know which ones, but
I have seen it lately as well :(

Regards

Marcel


