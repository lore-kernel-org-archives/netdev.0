From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] skge: allow WOL except for known broken chips
Date: Tue, 08 May 2007 01:16:52 -0400
Message-ID: <464007C4.3050007@pobox.com>
References: <20070507110155.2063c74d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54306 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967876AbXEHFQz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:16:55 -0400
In-Reply-To: <20070507110155.2063c74d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Wake On Lan works correctly on Yukon-FE and other variants.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>a
> 
> ---
>  drivers/net/skge.c |    9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)

applied


