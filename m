From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net] drivers: net: xen-netfront: remove residual
 dead code
Date: Mon, 12 Jan 2015 11:12:53 +0000
Message-ID: <54B3AC35.7070007@citrix.com>
References: <1420881625-4935-1-git-send-email-v.maffione@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <boris.ostrovsky@oracle.com>,
	<david.vrabel@citrix.com>
To: Vincenzo Maffione <v.maffione@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:22062 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbbALLM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2015 06:12:56 -0500
In-Reply-To: <1420881625-4935-1-git-send-email-v.maffione@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/15 09:20, Vincenzo Maffione wrote:
> This patch removes some unused arrays from the netfront private
> data structures. These arrays were used in "flip" receive mode.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Thanks.

David
