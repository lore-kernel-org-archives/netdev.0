From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] linux-2.4: br2684: fix double freeing skb
Date: Wed, 1 Jul 2009 08:49:37 +0200
Message-ID: <20090701064937.GA22396@1wt.eu>
References: <4A49C9BC.6050908@sphairon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Frank Seidel <Frank.Seidel@sphairon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:37072 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbZGAGt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 02:49:27 -0400
Content-Disposition: inline
In-Reply-To: <4A49C9BC.6050908@sphairon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 10:15:56AM +0200, Frank Seidel wrote:
> Author: Peter Sieber <siep@sphairon.com>
> 
> Fix double freeing skb, see net/core/dev.c
> dev_queue_xmit().
> 
> Signed-off-by: Peter Sieber <siep@sphairon.com>
> Signed-off-by: Frank Seidel <Frank.Seidel@sphairon.com>

queued for inclusion, thanks Frank!

Willy

