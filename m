From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 16/19] intel: convert drivers to netdev_tx_t
Date: Tue, 1 Sep 2009 18:03:00 -0700
Message-ID: <9929d2390909011803m28ce74b2rbd0fcec9bf74c61d@mail.gmail.com>
References: <20090901055039.824876937@vyatta.com>
	 <20090901055130.042455994@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:34177 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbZIBBC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 21:02:59 -0400
Received: by fxm17 with SMTP id 17so464029fxm.37
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 18:03:00 -0700 (PDT)
In-Reply-To: <20090901055130.042455994@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 22:50, Stephen Hemminger<shemminger@vyatta.com> wrote:
> Get rid of some bogus return wrapping as well.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Patch looks fine.

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
