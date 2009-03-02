From: Kyle McMartin <kyle@infradead.org>
Subject: Re: oops / null deref in __inet6_check_established(), kernel
	2.6.29-rc6
Date: Mon, 2 Mar 2009 12:18:35 -0500
Message-ID: <20090302171835.GL28503@bombadil.infradead.org>
References: <20090224.152704.210992553.davem@davemloft.net> <20090224183554.330eb308@dhcp-100-2-144.bos.redhat.com> <20090228031618.GB28503@bombadil.infradead.org> <20090301.213328.103151098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kyle@infradead.org, cebbert@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58309 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbZCBRSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 12:18:43 -0500
Content-Disposition: inline
In-Reply-To: <20090301.213328.103151098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 01, 2009 at 09:33:28PM -0800, David Miller wrote:
> 
> Pavel already submitted a fix for this and it's in my net-2.6
> tree and therefore will be sent to Linus soon.
> 
> And thanks so much for your amazing patience.
> 

Thanks for resolving this. Apologies I was too ignorant to see the patch
from Pavel. :/

regards, Kyle
