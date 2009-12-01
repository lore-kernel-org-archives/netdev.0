From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Add ll_index_to_addr function
Date: Tue, 1 Dec 2009 15:54:46 -0800
Message-ID: <20091201155446.37cee6a8@nehalam>
References: <1255632793-17779-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Ward <david.ward@ll.mit.edu>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42831 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754784AbZLAXzB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 18:55:01 -0500
In-Reply-To: <1255632793-17779-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2009 14:53:13 -0400
David Ward <david.ward@ll.mit.edu> wrote:

> After calling ll_init_map, all of the information stored in the link-layer map
> can be retrieved by function calls (ll_index_to_*), except for the link-layer
> address. This patch fills the gap by adding a ll_index_to_addr function.
> Changes welcome.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> ---

applied, thanks


-- 
