From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Thu, 03 May 2007 15:23:04 -0400
Message-ID: <463A3698.5020904@gentoo.org>
References: <20070430142349.79754c1b@freekitty>	<46374784.7010401@gentoo.org> <20070502154225.6c82a10d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org, Francois SIMOND <curio@free.fr>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.iad.emailsrvr.com ([207.97.245.111]:56291 "EHLO
	smtp111.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767754AbXECTXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 15:23:51 -0400
In-Reply-To: <20070502154225.6c82a10d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The PCI info is basically the same between working/non working
> Gigabyte boards. Is there any other difference?  Kernel config?
> chip revision?

I've never seen any reports of the corruption which you describe, so I 
can't make the comparison myself. Here's the chip info from a working 
Gigabyte DS3:

sky2 0000:04:00.0: v1.14 addr 0xf8000000 irq 16 Yukon-EC Ultra (0xb4) rev 2

Daniel
