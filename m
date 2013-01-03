From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] tcp: split tcp_ecn sysctl knob to distinguish between IPv4 and IPv6
Date: Thu, 3 Jan 2013 13:28:44 +0100
Message-ID: <20130103122844.GH4464@order.stressinduktion.org>
References: <20130103000009.GG4464@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33767 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab3ACM2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 07:28:46 -0500
Content-Disposition: inline
In-Reply-To: <20130103000009.GG4464@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2013 at 01:00:09AM +0100, Hannes Frederic Sowa wrote:
> ECN could be more reliable when used with IPv6 (I don't have proofs). For
> people who want to try ECN with IPv6 but still have problems connecting
> to destinations because of broken IPv4 routers this switch allows one
> to enable ECN just for IPv6.
> 
> Perhaps ECN could be enabled by default in future.
> 
> No code changes since initial submission, just added documentation.

May I ask what lead to the rejection of the patch?
