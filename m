From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 0/4] add MACsec support
Date: Thu, 14 Apr 2016 16:59:18 +0200
Message-ID: <20160414145918.GD3715@orbyte.nwl.cc>
References: <cover.1460622809.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58368 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752403AbcDNO7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 10:59:20 -0400
Content-Disposition: inline
In-Reply-To: <cover.1460622809.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 14, 2016 at 03:01:06PM +0200, Sabrina Dubroca wrote:
> This series introduces support for MACsec devices, with a new device
> type for `ip link`, and a new `ip macsec` subcommand.
> 
> The first three patches introduce some necessary helper functions.
> 
> Sabrina Dubroca (4):
>   utils: make hexstring_a2n provide the number of hex digits parsed
>   utils: add get_be{16,32,64}, use them where possible
>   utils: provide get_hex to read an hex digit from a char
>   ip: add MACsec support

Apart from the unrelated coding-style fix in patch 1 and the somewhat
intricate man page markup:

Acked-by: Phil Sutter <phil@nwl.cc>
