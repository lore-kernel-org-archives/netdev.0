From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: enable features before registering the
 driver
Date: Sun, 7 Apr 2013 12:11:21 +0200
Message-ID: <20130407121121.7a4b5446@skate>
References: <20130406184701.GA16142@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:43751 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933104Ab3DGKLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Apr 2013 06:11:35 -0400
In-Reply-To: <20130406184701.GA16142@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Willy Tarreau,

On Sat, 6 Apr 2013 20:47:01 +0200, Willy Tarreau wrote:

> From 005eb7594a4304eed5e9b427ca6b745260c9eded Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Mon, 11 Mar 2013 07:56:58 +0100
> Subject: [PATCH] net: mvneta: enable features before registering the
> driver, not after
> 
> It seems that the reason why the dev features were ignored was because
> they were enabled after registeration.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
