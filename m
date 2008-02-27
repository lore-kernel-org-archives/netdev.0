From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Wed, 27 Feb 2008 11:59:32 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0802271158100.1790@schroedinger.engr.sgi.com>
References: <47BDBC23.10605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>, travis@sgi.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:38124 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754234AbYB0T7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 14:59:34 -0500
In-Reply-To: <47BDBC23.10605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any decision made on what to do about this one? Mike or I can 
repost the per cpu allocator against mm? The fix by Eric could be used 
in the interim for 2.6.24?

