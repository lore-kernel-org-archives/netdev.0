From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Thu, 23 Jun 2016 00:15:04 +0200
Message-ID: <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:32992 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbcFVWPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 18:15:07 -0400
Received: by mail-oi0-f52.google.com with SMTP id u201so43608814oie.0
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 15:15:05 -0700 (PDT)
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 16, 2016 at 7:51 PM, Tom Herbert <tom@herbertland.com> wrote:
> Transports over UDP is intended to encapsulate TCP and other transport
> protocols directly and securely in UDP.
>
> The goal of this work is twofold:
>
> 1) Allow applications to run their own transport layer stack (i.e.from
>    userspace). This eliminates dependencies on the OS (e.g. solves a
>    major dependency issue for Facebook on clients).

Facebook on clients would be a Facebook app on mobile devices?
Does that mean that the Facebook app is so advanced and complicated
that it needs a special TCP stack?!

-- 
Thanks,
//richard
