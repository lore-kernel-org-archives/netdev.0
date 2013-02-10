From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: by default join ff01::1 and in case of forwarding ff01::2 and ff05:2
Date: Sun, 10 Feb 2013 14:42:53 +0100
Message-ID: <20130210134253.GE18219@order.stressinduktion.org>
References: <20130210133431.GD18219@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55406 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754674Ab3BJNmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 08:42:54 -0500
Content-Disposition: inline
In-Reply-To: <20130210133431.GD18219@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch is flawed, will resend, sorry.

On Sun, Feb 10, 2013 at 02:34:31PM +0100, Hannes Frederic Sowa wrote:
> Cc: Erik Hugne <erik.hugne@ericsson.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/in6.h |  9 +++++++++
>  net/ipv6/addrconf.c | 15 +++++++++++++--
>  2 files changed, 22 insertions(+), 2 deletions(-)
