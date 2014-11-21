From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [iproute2,v4] tc: add support for vlan tc action
Date: Fri, 21 Nov 2014 12:27:44 +0100
Message-ID: <20141121112744.GA1932@nanopsycho.brq.redhat.com>
References: <CAMw6YJK0_TLrqcUTkrE9rX_rbgJQ5-3O5D7ToBZvbPCNyaK3yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:41768 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758116AbaKUL1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 06:27:53 -0500
Received: by mail-wg0-f45.google.com with SMTP id b13so6297400wgh.18
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2014 03:27:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAMw6YJK0_TLrqcUTkrE9rX_rbgJQ5-3O5D7ToBZvbPCNyaK3yQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Nov 21, 2014 at 12:10:04PM CET, vadim4j@gmail.com wrote:
>Hi,
>
>> + fprintf(stderr, "unexpexted \"%s\" - action already specified\n",
>> + *argv);
>
>
>Seems like typo in "unexpexted" ?

Thanks, will fix.

>
>Regards,
>Vadim Kochan
