From: Jeff Dike <jdike@addtoit.com>
Subject: Re: [PATCH 14/21] uml: enable scsi and add iscsi config
Date: Mon, 11 Sep 2006 11:49:33 -0400
Message-ID: <20060911154933.GC4443@ccure.user-mode-linux.org>
References: <20060906131630.793619000@chello.nl>> <20060906133955.337828000@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>,
	Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saraswathi.solana.com ([198.99.130.12]:59843 "EHLO
	saraswathi.solana.com") by vger.kernel.org with ESMTP
	id S1751313AbWIKPvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 11:51:44 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Disposition: inline
In-Reply-To: <20060906133955.337828000@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 06, 2006 at 03:16:44PM +0200, Peter Zijlstra wrote:
> Enable iSCSI on UML, dunno why SCSI was deemed broken, it works like a charm.

Acked-by: Jeff Dike <jdike@addtoit.com>

Although it would be nice if we didn't have to copy bits of Kconfig files
to do this.

				Jeff
