From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netdev: convert non-obvious instances to use ARRAY_SIZE()
Date: Mon, 15 Oct 2007 16:05:44 -0400
Message-ID: <4713C818.1070205@pobox.com>
References: <20071015013743.GB21622@inspiron>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alejandro Martinez Ruiz <alex@flawedcode.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36833 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933321AbXJOUFs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 16:05:48 -0400
In-Reply-To: <20071015013743.GB21622@inspiron>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alejandro Martinez Ruiz wrote:
> This will convert remaining non-obvious or naive calculations of array
> sizes to use ARRAY_SIZE() macro.
> 
> Signed-off-by: Alejandro Martinez Ruiz <alex@flawedcode.org>
> ---
>  drivers/net/cassini.c       |    2 +-
>  drivers/net/irda/donauboe.c |    2 +-
>  drivers/net/ne-h8300.c      |    4 ++--
>  drivers/net/tg3.c           |    2 +-
>  drivers/net/tulip/de4x5.c   |    4 ++--
>  drivers/net/wan/sdla.c      |    8 ++++----
>  6 files changed, 11 insertions(+), 11 deletions(-)

applied


