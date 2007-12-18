From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Dump the eeprom when a user encounters a bad checksum
Date: Mon, 17 Dec 2007 20:17:58 -0500
Message-ID: <47671FC6.6010200@garzik.org>
References: <20071217215023.26270.62396.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	randy.dunlap@oracle.com, joe@perches.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34160 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762385AbXLRBSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:18:01 -0500
In-Reply-To: <20071217215023.26270.62396.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> To help supporting users with a bad eeprom checksum, dump the
> eeprom info when such a situation is encountered by a user.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   85 +++++++++++++++++++++++++++++++++++-----
>  1 files changed, 74 insertions(+), 11 deletions(-)

applied #upstream


