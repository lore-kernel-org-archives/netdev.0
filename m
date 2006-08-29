From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 11/26] e1000: clean up skb allocation code, patch submitted
 by Christoph
Date: Tue, 29 Aug 2006 16:52:58 -0400
Message-ID: <44F4A92A.6060909@pobox.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164439.6872.18771.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55436 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965314AbWH2UxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:53:00 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060829164439.6872.18771.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

ACK, but please don't include attribution in the subject line.

Add a "From: ...author..." as the first line of your patch description 
instead.

See #12 of Documentation/SubmittingPatches for more info.

	Jeff


