From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] add NAPI support to sb1250-mac.c (take 2)
Date: Tue, 03 Apr 2007 22:33:20 -0400
Message-ID: <46130E70.9030305@pobox.com>
References: <20070329194240.GA11810@upwardaccess.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: Mark Mason <mmason@upwardaccess.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40273 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966295AbXDDCdW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 22:33:22 -0400
In-Reply-To: <20070329194240.GA11810@upwardaccess.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Mason wrote:
> Patch to add NAPI support to sb1250-mac.c (rev 2).  This patch differs from
> the last in that the NAPI support isn't marked as experimental, nor is it
> configurable (ie. once applied - NAPI is enabled all the time).  This was
> based on feedback from Ralf and others.
> 
> Signed-off-by: Mark Mason <mason@broadcom.com>
> 
> ---
>  drivers/net/sb1250-mac.c |  278 ++++++++++++++++++++++++++++++----------------
>  1 files changed, 182 insertions(+), 96 deletions(-)

seems OK but doesn't apply

