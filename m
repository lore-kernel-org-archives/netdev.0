From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bpf filter : support for vlan tag
Date: Fri, 26 Oct 2012 10:16:04 +0200
Message-ID: <1351239364.6537.292.camel@edumazet-glaptop>
References: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
	 <1350369998.3954.563.camel@edumazet-glaptop>
	 <CAD6jFUTn98+i_0eh6gc-CYgVXHNLbZdZmV6==mL+duFM-oNRmg@mail.gmail.com>
	 <1350386917.3954.890.camel@edumazet-glaptop>
	 <CAD6jFUQ+F4nBu6WmC6pW2GLSeUy+QfHngT=5NStt=2BRQFnA4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ani Sinha <ani@aristanetworks.com>, netdev@vger.kernel.org
To: Daniel Borkmann <danborkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55211 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932118Ab2JZIQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:16:09 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1131486bkc.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 01:16:07 -0700 (PDT)
In-Reply-To: <CAD6jFUQ+F4nBu6WmC6pW2GLSeUy+QfHngT=5NStt=2BRQFnA4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-26 at 10:05 +0200, Daniel Borkmann wrote:

> Eric, can you submit this patch to net-next if there are no objections
> from your side regarding the follow-up comments? Big thanks.

Yep, I am preparing two patches :

1) Generic support

2) x86_64 jit support
