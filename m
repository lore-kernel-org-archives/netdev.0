From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] net: qdisc: enhance default_qdisc documentation
Date: Wed, 16 Sep 2015 14:09:03 -0700
Message-ID: <CAHA+R7MinLHMC3S0+9UFhbd72aO+hLq5LXr4jbb=0rxb92vxQg@mail.gmail.com>
References: <1442305987-6559-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:34251 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbbIPVJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 17:09:04 -0400
Received: by ykdg206 with SMTP id g206so232278338ykd.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 14:09:03 -0700 (PDT)
In-Reply-To: <1442305987-6559-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 1:33 AM, Phil Sutter <phil@nwl.cc> wrote:
> Aside from some lingual cleanup, point out which interfaces are not or
> partly covered by this setting.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Acked-by: Cong Wang <cwang@twopensource.com>

It also worth to explain what the default qdisc means, but we can do
that in another patch.

Thanks.
