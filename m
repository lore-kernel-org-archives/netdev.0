From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] netfilter: replace horrible hack with ksize()
Date: Wed, 5 Mar 2008 13:56:13 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0803051355140.31527@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, joe@perches.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:59558 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764062AbYCEV4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 16:56:25 -0500
In-Reply-To: <Pine.LNX.4.64.0803052319210.15759@sbz-30.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Christoph Lameter <clameter@sgi.com>

I guess this should go through the netdev tree?


