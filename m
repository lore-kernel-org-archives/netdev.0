From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] sky2: add Wake On Lan support
Date: Tue, 06 Feb 2007 19:20:56 -0500
Message-ID: <45C91B68.4090900@pobox.com>
References: <20070206184538.675048000@linux-foundation.org> <20070206184854.882274000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56717 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030274AbXBGAU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 19:20:58 -0500
In-Reply-To: <20070206184854.882274000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Adds basic magic packet wake on lan support to the sky2 driver.
> Note: initial WOL value is based on BIOS settings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
>  drivers/net/sky2.c |  208 ++++++++++++++++++++++++++++++++++++++++++++++-------
>  drivers/net/sky2.h |   28 ++-----
>  2 files changed, 189 insertions(+), 47 deletions(-)

applied 1-7


