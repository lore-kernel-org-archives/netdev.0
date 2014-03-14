From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V6 net-next 5/5] xen-net{back,front}: Document
 multi-queue feature in netif.h
Date: Fri, 14 Mar 2014 16:04:50 +0000
Message-ID: <1394813090.6442.134.camel@kazak.uk.xensource.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
	 <1393847269-6981-6-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:50904 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754743AbaCNQE7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 12:04:59 -0400
In-Reply-To: <1393847269-6981-6-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-03 at 11:47 +0000, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Document the multi-queue feature in terms of XenStore keys to be written
> by the backend and by the frontend.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> ---
>  include/xen/interface/io/netif.h |   29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
> index c50061d..a375a75 100644
> --- a/include/xen/interface/io/netif.h
> +++ b/include/xen/interface/io/netif.h

I assume this is (going to be) identical to the patch to the Xen copy of
these headers. So once I ack that feel free to sync the text and apply
the ack here too.

Ian.
