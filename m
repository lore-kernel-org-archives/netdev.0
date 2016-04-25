From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] devlink: export header
Date: Mon, 25 Apr 2016 16:03:37 -0700
Message-ID: <20160425160337.576a3b92@xeon-e3>
References: <20160422095517.545fe658@xeon-e3>
	<20160425.164928.589496341257465225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35128 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751860AbcDYXDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 19:03:25 -0400
Received: by mail-pa0-f43.google.com with SMTP id iv1so20962270pac.2
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 16:03:25 -0700 (PDT)
In-Reply-To: <20160425.164928.589496341257465225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Apr 2016 16:49:28 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Fri, 22 Apr 2016 09:55:17 -0700
> 
> > Export devlink.h when doing make headers install.
> > I am going to investigate just doing all headers in the directory,
> > but lets add missing piece for now.
> > 
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> This is already exported in the 'net' tree.

ok, thanks
