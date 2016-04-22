From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH iproute2 0/4] add MACsec support
Date: Fri, 22 Apr 2016 18:10:31 +0200
Message-ID: <20160422161031.GA20140@bistromath.localdomain>
References: <cover.1460622809.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41275 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753881AbcDVQKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 12:10:35 -0400
Content-Disposition: inline
In-Reply-To: <cover.1460622809.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-14, 15:01:06 +0200, Sabrina Dubroca wrote:
> This series introduces support for MACsec devices, with a new device
> type for `ip link`, and a new `ip macsec` subcommand.
> 
> The first three patches introduce some necessary helper functions.

Hi Stephen,

Please don't apply this yet, I'm updating uapi:
http://marc.info/?l=linux-netdev&m=146131733302850&w=2

Thanks,

-- 
Sabrina
