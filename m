From: Michael Dalton <mwdalton@google.com>
Subject: Re: [PATCH net-next v4 1/6] net: allow > 0 order atomic page alloc in skb_page_frag_refill
Date: Thu, 16 Jan 2014 16:30:11 -0800
Message-ID: <CANJ5vPLZZKqPxZ6yC4sympZODy5h0NjrOTkNS3g+ZG6_9KUi=w@mail.gmail.com>
References: <1389901950-3854-1-git-send-email-mwdalton@google.com>
 <20140116.152800.901405996505782677.davem@davemloft.net> <20140116.153020.587523865163482894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	lf-virt <virtualization@lists.linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:57436 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbaAQAac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:30:32 -0500
Received: by mail-oa0-f48.google.com with SMTP id i11so3815254oag.35
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 16:30:31 -0800 (PST)
In-Reply-To: <20140116.153020.587523865163482894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 16, 2014 at 3:30 PM, David Miller <davem@davemloft.net> wrote:
> Actually, I reverted, please resubmit this series with the following
> build warning corrected:

Thanks David, I will send out another patchset shortly with the warning
resolved and a header e-mail (and one other sysfs group fix that I just
found in the same file). Sorry I didn't include a header e-mail
initially.

Best,

Mike
