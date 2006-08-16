From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [take9 0/2] kevent: Generic event handling mechanism.
Date: Wed, 16 Aug 2006 14:26:31 +0100
Message-ID: <20060816132631.GA32499@infradead.org>
References: <20060731103322.GA1898@2ka.mipt.ru> <11555364962921@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:32978 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750956AbWHPN0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 09:26:53 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <11555364962921@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2006 at 10:21:36AM +0400, Evgeniy Polyakov wrote:
> 
> Generic event handling mechanism.

Hi, I've just started looking into this, so some comments here first
on the submission process:

 - could you send new revisions of the patches in a new thread so one can
   easily find them?
 - the patch split is not very nice, your first patch adds Makefile and
   Kconfig entries for files only in the second patch or not actually
   submitted at all, that's a big no-no.

