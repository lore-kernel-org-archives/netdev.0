From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
Date: Fri, 21 Mar 2008 10:31:37 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0803211031290.18671@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061727.491610308@sgi.com>
 <47E35D73.6060703@cosmosbay.com> <20080321.003100.155729406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:48768 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751500AbYCURdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2008 13:33:10 -0400
In-Reply-To: <20080321.003100.155729406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Mar 2008, David Miller wrote:

> I agree with Eric, converting any of the networking hash
> allocations to this new facility is not the right thing
> to do.

Ok. Going to drop it.
 
