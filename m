From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: sit: ensure prefixlen <= 128 before calling ipv6_addr_prefix
Date: Sun, 29 Sep 2013 05:53:57 +0200
Message-ID: <20130929035357.GC8602@order.stressinduktion.org>
References: <20130929031535.GA8602@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57866 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab3I2Dx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 23:53:58 -0400
Content-Disposition: inline
In-Reply-To: <20130929031535.GA8602@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 29, 2013 at 05:15:35AM +0200, Hannes Frederic Sowa wrote:
> Found with coverity: CID 139492
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Disregard, I was fooled by the report. This is not necessary.
