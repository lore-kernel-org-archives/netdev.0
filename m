From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC 01/23] xen: Include xen/page.h rather than asm/xen/page.h
Date: Tue, 19 May 2015 14:50:54 +0100
Message-ID: <555B3FBE.8030408@citrix.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
 <1431622863-28575-2-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <netdev@vger.kernel.org>,
	<tim@xen.org>, <linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431622863-28575-2-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/05/15 18:00, Julien Grall wrote:
> Using xen/page.h will be necessary later for using common xen page
> helpers.
> 
> As xen/page.h already include asm/xen/page.h, always use the later.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
