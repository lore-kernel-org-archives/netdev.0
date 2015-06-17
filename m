From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v2 0/7] xen: Clean up
Date: Wed, 17 Jun 2015 16:36:47 +0100
Message-ID: <5581940F.6020102@citrix.com>
References: <1434551288-14113-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	<linux-kernel@vger.kernel.org>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>,
	=?UTF-8?B?Um9nZXIgUGF1IE1vbm7DqQ==?= <roger.pau@citrix.com>
To: Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434551288-14113-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/06/15 15:28, Julien Grall wrote:
> Hi,
> 
> Thoses patches was originally part of the Xen 64KB series [1]. Although,
> I think they can go without waiting the rest of the 64KB series.
> 
> Patch #1-#4 should go through the Xen tree, even though patch #1 touches
> multiple part.
> 
> Patch #5-#7 should go through the Block tree.

I've applied all of these to for-linus-4.2, thanks.  Including the block
ones since they were trivial and not block-related.

David
