From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3 1/5] add missing if_macsec.h header from
 kernel
Date: Mon, 23 May 2016 16:07:20 -0700
Message-ID: <20160523160720.69bcd2ef@xeon-e3>
References: <cover.1463585050.git.sd@queasysnail.net>
	<87b1f9795592d29be689943e2b8ec9712bda056b.1463585050.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34160 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752887AbcEWXHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 19:07:08 -0400
Received: by mail-pa0-f49.google.com with SMTP id qo8so15465pab.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 16:07:07 -0700 (PDT)
In-Reply-To: <87b1f9795592d29be689943e2b8ec9712bda056b.1463585050.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 May 2016 17:35:09 +0200
Sabrina Dubroca <sd@queasysnail.net> wrote:

> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Acked-by: Phil Sutter <phil@nwl.cc>

This header already exists in master branch of iproute2, with current version
from upstream kernel (with PAD values).
