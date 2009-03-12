From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 14:58:28 +0200
Message-ID: <1295ed070903120558u33d633f4v1622ef56a06066a0@mail.gmail.com>
References: <200903121946.24847.rusty@rustcorp.com.au>
	 <1236858219.14863.18.camel@localhost.localdomain>
	 <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
	 <20090312.055235.56926675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:58631 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244AbZCLM6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 08:58:31 -0400
Received: by ewy25 with SMTP id 25so346433ewy.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 05:58:29 -0700 (PDT)
In-Reply-To: <20090312.055235.56926675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If the link is always on, you should make that explicit by providing
> a link state handler, and making sure it always returns true.

So, you agree that my patch that does exactly that is correct ?

Pantelis
