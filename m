From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v4 4/4] ip: add MACsec support
Date: Wed, 8 Jun 2016 09:37:39 -0700
Message-ID: <20160608093739.0edea430@xeon-e3>
References: <cover.1464963543.git.sd@queasysnail.net>
	<d835c2e55dc2fbf604dc8819fd44ccca25a609b1.1464963543.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33792 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424602AbcFHQh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 12:37:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id bz2so3953661pad.1
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 09:37:26 -0700 (PDT)
In-Reply-To: <d835c2e55dc2fbf604dc8819fd44ccca25a609b1.1464963543.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  3 Jun 2016 16:45:48 +0200
Sabrina Dubroca <sd@queasysnail.net> wrote:

> Extend ip-link to create MACsec devices
> 
>   ip link add link <master> <macsec> type macsec [options]
> 
> Add `ip macsec` command to configure receive-side secure channels and
> secure associations within a macsec netdevice.
> 
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Acked-by: Phil Sutter <phil@nwl.cc>

Applied.
