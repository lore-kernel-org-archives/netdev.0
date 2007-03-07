From: Matt Mackall <mpm@selenic.com>
Subject: Re: [RFC: net-2.6.20 patch] remove unused exports
Date: Wed, 7 Mar 2007 16:36:50 -0600
Message-ID: <20070307223650.GX23311@waste.org>
References: <20070307224059.GA3441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:34870 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992809AbXCGWuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 17:50:01 -0500
Content-Disposition: inline
In-Reply-To: <20070307224059.GA3441@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2007 at 11:40:59PM +0100, Adrian Bunk wrote:
> This patch removes the following not or no longer used exports:
> - drivers/char/random.c: secure_tcp_sequence_number

This part looks reasonable.

Acked-by: Matt Mackall <mpm@selenic.com>
-- 
Mathematics is the supreme nostalgia of our time.
