From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2]via-rhine.c: Use-register-offset-definition-for-WOLcgClr
Date: Sun, 24 Feb 2008 00:11:31 -0500
Message-ID: <47C0FC83.40303@garzik.org>
References: <E1JSybz-0004BD-Tu@elite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Laura Garcia <nevola@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50428 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912AbYBXFLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 00:11:33 -0500
In-Reply-To: <E1JSybz-0004BD-Tu@elite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Laura Garcia wrote:
> Use register offset definition for WOLcgClr. This patch does not 
> change the driver behaviour.
> 
> Signed-off-by: Laura Garcia Liebana <nevola@gmail.com>
> 
> 	modified:   drivers/net/via-rhine.c
> ---
>  drivers/net/via-rhine.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied, after making the following manual edits:

- removed "modified: ..." line, that is redundant to the diffstat, and 
being before the "---" separator, it is included in the changelog by 
automated tools

- removed all the silly dashes from the subject line.  we want something 
readable, not a filename.


