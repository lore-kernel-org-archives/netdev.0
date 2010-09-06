From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: usbnet: doc updates
Date: Sun, 05 Sep 2010 21:57:59 -0700 (PDT)
Message-ID: <20100905.215759.193704169.davem@davemloft.net>
References: <414445.95907.qm@web180304.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@rainbow-software.org
To: david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60847
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751170Ab0IFE5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 00:57:42 -0400
In-Reply-To: <414445.95907.qm@web180304.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <david-b@pacbell.net>
Date: Sun, 5 Sep 2010 21:48:01 -0700 (PDT)

> If I had my normal mail access, I'd send this
> patch inline; but I don't.

The problem is that you set the content type to octet stream with
base64 encoding, which patchwork can't handle.

Set it to something like text/plain with UTF8 encoding, and all should
be well.

Thanks.
