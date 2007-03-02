From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Fri, 2 Mar 2007 11:11:36 +0100
Message-ID: <200703021111.36281.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <200703011230.50596.dada1@cosmosbay.com> <45E7EDE1.30805@free.fr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: John <linux.kernel@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:41228 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423000AbXCBKLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 05:11:42 -0500
In-Reply-To: <45E7EDE1.30805@free.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 02 March 2007 10:26, John wrote:
> Eric Dumazet wrote:

> > Anyway, if you want to play, you can apply this patch on top of
> > linux-2.6.21-rc2  (nanosecond resolution infrastructure needs 2.6.21)
> > I let you do the adjustments for rt kernel.
>
> Why does it require 2.6.21?

Well, this patch was done on top of the latest kernel for obvious practical 
reasons, but you probably can adapt it on the kernel of your choice.

