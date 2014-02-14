From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH V3 net-next 5/5] xen-net{back,	front}: Document
 multi-queue feature in netif.h
Date: Fri, 14 Feb 2014 18:23:16 +0000
Message-ID: <52FE5F14.50203@citrix.com>
References: <1392399353-11973-1-git-send-email-andrew.bennieston@citrix.com> <1392399353-11973-6-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<paul.durrant@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:18704 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751721AbaBNSXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 13:23:18 -0500
In-Reply-To: <1392399353-11973-6-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/02/14 17:35, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Document the multi-queue feature in terms of XenStore keys to be written
> by the backend and by the frontend.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> ---
>  include/xen/interface/io/netif.h |   21 +++++++++++++++++++++

The master copy of this file is in Xen. You will need to prepare and
submit a similar patch to xen-devel.

David
