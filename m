From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v2 0/4] net: support MPLS in IPv4 and UDP
Date: Sun, 10 Jul 2016 09:12:00 +0900
Message-ID: <20160710001158.GA12121@penelope.isobedori.kobe.vergenet.net>
References: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
 <20160709.174732.2005655639608493530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32872 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbcGJAMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 20:12:05 -0400
Received: by mail-pa0-f46.google.com with SMTP id b13so23120152pat.0
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 17:12:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160709.174732.2005655639608493530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 09, 2016 at 05:47:32PM -0400, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Thu,  7 Jul 2016 07:56:11 +0200
> 
> > This short series provides support for MPLS in IPv4 (RFC4023), and by
> > virtue of FOU, MPLS in UDP (RFC7510).
> 
> Series applied, thanks Simon.

Thanks.

It looks like I messed up the error path in
"tunnels: support MPLS over IPv4 tunnels" as flagged by the
kbuild test robot.

I'll get a fix for that to you soon.
