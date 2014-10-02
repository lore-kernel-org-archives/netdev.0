From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH iproute2 v2] iplink: do not require assigning negative
 ifindex at link creation
Date: Wed, 1 Oct 2014 21:16:35 -0700
Message-ID: <CAHA+R7MtzbUTy6Cgun5pLvdXSHaf30mSjuBb9UbNJw+dB83WRg@mail.gmail.com>
References: <87tx3o5ojd.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:55392 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaJBEQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 00:16:36 -0400
Received: by mail-lb0-f171.google.com with SMTP id z12so1572358lbi.16
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 21:16:35 -0700 (PDT)
In-Reply-To: <87tx3o5ojd.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 10:47 PM, Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> Since commit 3c682146aeff, iplink requires assigning negative
> ifindex (-1) to the kernel when creating interface without
> specifying index.
>
> v2: checking whether index is -1, suggested by Cong Wang.
>
> Cc: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Acked-by:  Cong Wang <cwang@twopensource.com>

Thanks!
