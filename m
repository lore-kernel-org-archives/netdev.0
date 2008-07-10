From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 13/13]: niu: Add TX multiqueue support.
Date: Thu, 10 Jul 2008 21:14:45 +0400
Message-ID: <20080710171445.GA5146@2ka.mipt.ru>
References: <20080710.035729.69923246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:57121 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751251AbYGJROv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 13:14:51 -0400
Content-Disposition: inline
In-Reply-To: <20080710.035729.69923246.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Jul 10, 2008 at 03:57:29AM -0700, David Miller (davem@davemloft.net) wrote:
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/niu.c |   45 +++++++++++++++++++++++++--------------------
>  1 files changed, 25 insertions(+), 20 deletions(-)

Out of curiosity, are there some nice graphs of the new multiqueue
transfer performance or anything like that?

-- 
	Evgeniy Polyakov
