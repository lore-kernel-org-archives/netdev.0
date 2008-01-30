From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/7] bonding: fix parameter parsing
Date: Wed, 30 Jan 2008 03:38:39 -0500
Message-ID: <47A0378F.4050700@pobox.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com> <12016588701127-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47015 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752870AbYA3Iim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 03:38:42 -0500
In-Reply-To: <12016588701127-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	My last fix (commit ece95f7fefe3afae19e641e1b3f5e64b00d5b948)
> didn't handle one case correctly.  This resolves that, and it will now
> correctly parse parameters with arbitrary white space, and either text
> names or mode values.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> ---
>  drivers/net/bonding/bond_main.c |   17 +++++++++++------
>  1 files changed, 11 insertions(+), 6 deletions(-)

applied 1-7


