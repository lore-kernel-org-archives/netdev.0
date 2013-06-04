From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [ PATCH iproute2] ss: replace bfp with bpf in usage().
Date: Mon, 3 Jun 2013 19:57:38 -0700
Message-ID: <20130603195738.45b8613e@nehalam.linuxnetplumber.net>
References: <1369388560-6030-1-git-send-email-ramirose@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:58162 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756130Ab3FDC5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 22:57:41 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so856540pdi.36
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 19:57:41 -0700 (PDT)
In-Reply-To: <1369388560-6030-1-git-send-email-ramirose@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 May 2013 12:42:40 +0300
Rami Rosen <ramirose@gmail.com> wrote:

> This patch fixes usage() of misc/ss.c to use bpf instead of bfp.
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Applied
