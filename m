From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/4] add MACsec support
Date: Fri, 22 Apr 2016 09:30:32 -0700
Message-ID: <20160422093032.4e851fa9@xeon-e3>
References: <cover.1460622809.git.sd@queasysnail.net>
	<20160422161031.GA20140@bistromath.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36780 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbcDVQaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 12:30:21 -0400
Received: by mail-pa0-f48.google.com with SMTP id er2so41144774pad.3
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 09:30:21 -0700 (PDT)
In-Reply-To: <20160422161031.GA20140@bistromath.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Apr 2016 18:10:31 +0200
Sabrina Dubroca <sd@queasysnail.net> wrote:

> 2016-04-14, 15:01:06 +0200, Sabrina Dubroca wrote:
> > This series introduces support for MACsec devices, with a new device
> > type for `ip link`, and a new `ip macsec` subcommand.
> > 
> > The first three patches introduce some necessary helper functions.
> 
> Hi Stephen,
> 
> Please don't apply this yet, I'm updating uapi:
> http://marc.info/?l=linux-netdev&m=146131733302850&w=2
> 
> Thanks,

Sure, was holding for a couple weeks of review anyway.
