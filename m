From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] ip: Add label option to ip monitor
Date: Mon, 19 Aug 2013 08:58:47 -0700
Message-ID: <20130819085847.5dd5b972@nehalam.linuxnetplumber.net>
References: <20130819154330.77c29d55@martins.ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Martin Schwenke <martin@meltin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35774 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836Ab3HSP6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:58:54 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so1841011pab.34
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 08:58:54 -0700 (PDT)
In-Reply-To: <20130819154330.77c29d55@martins.ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Aug 2013 15:43:30 +1000
Martin Schwenke <martin@meltin.net> wrote:

> Prefix labelling is currently only activated when monitoring "all"
> objects.  However, the output can still be confusing when monitoring
> more than 1 object, so add an option to always print prefix labels.
> 
> Signed-off-by: Martin Schwenke <martin@meltin.net>
> ---
> Really a reply to http://www.spinics.net/lists/netdev/msg246739.html

Thanks, applied.
