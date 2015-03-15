From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] ip: allow using a device "help" (or a prefix
 thereof)
Date: Mon, 16 Mar 2015 01:49:17 +0200
Message-ID: <20150315234917.GA7105@angus-think.lan>
References: <1426462817-18366-1-git-send-email-develop@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, vadim4j@gmail.com, leonhard@pre.is
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:34777 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbbCPAA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 20:00:56 -0400
Received: by lbbsy1 with SMTP id sy1so21060580lbb.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 17:00:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426462817-18366-1-git-send-email-develop@kristov.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 12:40:17AM +0100, Christoph Schulz wrote:
> Device names that match "help" or a prefix thereof should be allowed anywhere
> a device name can be used. Note that a suitable keyword ("dev" or "name", the
> latter for "ip tunnel") has to be used in these cases to resolve ambiguities.
> 
> Signed-off-by: Christoph Schulz <develop@kristov.de>
> Reported-by: Leonhard Preis <leonhard@pre.is>
> ---

I don't know if it is important but I see this patch in the patchwork

	http://patchwork.ozlabs.org/patch/450257/

as superseded, is it OK ?

Regards,
