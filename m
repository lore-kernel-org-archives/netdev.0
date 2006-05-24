From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] au1000_eth.c: use ether_crc() from <linux/crc32.h>
Date: Wed, 24 May 2006 01:29:48 -0400
Message-ID: <4473EF4C.9010104@pobox.com>
References: <E1FaYil-0007A8-HB@fencepost.gnu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
	sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:7392 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932594AbWEXF3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 01:29:50 -0400
To: Herbert Valerio Riedel <hvr@gnu.org>
In-Reply-To: <E1FaYil-0007A8-HB@fencepost.gnu.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Valerio Riedel wrote:
> since the au1000 driver already selects the CRC32 routines, simply replace
> the internal ether_crc() implementation with the semantically equivalent
> one from <linux/crc32.h>
> 
> Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>

does not apply, please resend


