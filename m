From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 08/12] r8169: cleanup
Date: Tue, 08 May 2007 00:52:08 -0400
Message-ID: <464001F8.80805@garzik.org>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com> <20070426214856.GI7344@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54106 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967752AbXEHEwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 00:52:12 -0400
In-Reply-To: <20070426214856.GI7344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> No functionnal change:
> - trim the old history log
> - whitespace/indent/case police
> - unsigned int where signedness does not matte
> - removal of obsolete assert
> - needless cast from void * (dev_instance)
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com>
> ---
>  drivers/net/r8169.c |  311 ++++++++++++++++++++++-----------------------------
>  1 files changed, 133 insertions(+), 178 deletions(-)

ACK patches 1-8


