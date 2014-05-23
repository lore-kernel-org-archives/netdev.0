From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Fri, 23 May 2014 16:51:17 -0700
Message-ID: <CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org>
	<536AB151.2070804@dti2.net>
	<CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com>
	<20140507.185256.496391962242529591.davem@davemloft.net>
	<CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
	<CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com>
	<CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com>
	<20140522170505.64ef87a2@griffin>
	<87ioow6pt6.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f173.google.com ([209.85.128.173]:41420 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017AbaEWXvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 19:51:18 -0400
Received: by mail-ve0-f173.google.com with SMTP id pa12so7133760veb.32
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 16:51:17 -0700 (PDT)
In-Reply-To: <87ioow6pt6.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 23, 2014 at 4:25 PM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> I have not seen consensus that what Zebra is doing makes sense to
> support.

Eric, stop right there.

There is no "sensible to support". There is only "reality".

The thing that makes "reality" be "reality" is that it exists whether
you like it or not, or whether you believe in it or not.

We don't break applications. Whether you like them or not is
completely immaterial.

                Linus
