From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [NET] Fixed a small typo in the loopback driver
Date: Sat, 12 Jan 2008 17:41:33 -0500
Message-ID: <4789421D.2050707@pobox.com>
References: <1198765042-30349-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Emil Medve <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51085 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758589AbYALWlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 17:41:37 -0500
In-Reply-To: <1198765042-30349-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emil Medve wrote:
> This is probably a result of the changes from commit
> 854d836 - [NET]: Dynamically allocate the loopback device, part 2
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
> 
> linux-2.6> scripts/checkpatch.pl 0001-NET-Fixed-a-small-typo-in-the-loopback-driver.patch 
> total: 0 errors, 0 warnings, 8 lines checked
> 
> Your patch has no obvious style problems and is ready for submission.
> 
> 
>  drivers/net/loopback.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied


