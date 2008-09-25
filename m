From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 12/21] netdev: drop CONFIG_PPC_MERGE from Kconfig
Date: Wed, 24 Sep 2008 22:15:31 -0400
Message-ID: <48DAF443.5080803@garzik.org>
References: <200809222152.m8MLqJsW031972@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galak@kernel.crashing.org,
	benh@kernel.crashing.org, david@gibson.dropbear.id.au,
	jwboyer@linux.vnet.ibm.com, paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55420 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752699AbYIYCPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:15:36 -0400
In-Reply-To: <200809222152.m8MLqJsW031972@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Kumar Gala <galak@kernel.crashing.org>
> 
> Now that arch/ppc is dead CONFIG_PPC_MERGE is always defined for all
> powerpc platforms so we don't need to depend on it.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> Cc: David Gibson <david@gibson.dropbear.id.au>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/Kconfig             |    2 +-
>  drivers/net/ibm_newemac/Kconfig |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

applied

