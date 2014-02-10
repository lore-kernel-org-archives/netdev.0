From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: Fix Netid value for multi-families output
Date: Mon, 10 Feb 2014 14:48:56 -0800
Message-ID: <20140210144856.4c064f32@nehalam.linuxnetplumber.net>
References: <52E74D0F.4050806@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	=?ISO-8859-1?B?RnJhbudvaXMtWGF2aWVy?= Le Bail
	<fx.lebail@yahoo.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:38087 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbaBJWs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 17:48:59 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so6661343pde.6
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 14:48:58 -0800 (PST)
In-Reply-To: <52E74D0F.4050806@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jan 2014 10:24:15 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> When requesting simultaneous output of TCP and UDP sockets
> the netid field shows "tcp" always.

Applied
