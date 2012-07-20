From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: Re: [PATCH] b44: add 64 bit stats
Date: Fri, 20 Jul 2012 14:56:48 -0400
Message-ID: <CABF+-6Ubh6rSYV=L8-QV466XNo5OqCxA+4DRqXGdELhnSPkPZQ@mail.gmail.com>
References: <CABF+-6XaYk8qXnFNXF_+rQ144jyDFgFqDVKsuZv+S_0VZxBAvw@mail.gmail.com>
	<1342337165.3265.10640.camel@edumazet-glaptop>
	<CABF+-6XVCTDZedzcp-gWACYpG9NLmZUdwW2zsXC8WNKWk3dE5w@mail.gmail.com>
	<1342759989.2626.5472.camel@edumazet-glaptop>
	<1342761865.2626.5572.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:45514 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016Ab2GTS4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:56:49 -0400
Received: by vcbfk26 with SMTP id fk26so3252391vcb.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 11:56:48 -0700 (PDT)
In-Reply-To: <1342761865.2626.5572.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 20, 2012 at 1:24 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> Absolutely. You can argue that probably nobody use this driver on a
>> 32bit UP machine, but technically speaking the current implementation is
>> racy.
>
> In fact all network drivers should use the _bh version.

Okay, thanks for clarifying.

> Could you send a patch for all of them, based on net-next tree ?

Sure, I can work on that.  It should be a relatively easy thing to
update.  I can probably send a patch within the next couple days.


Kevin
