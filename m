From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: To netlink or not to netlink, that is the question
Date: Thu, 12 Jan 2017 19:28:20 +0100
Message-ID: <CAHmME9rWDzO9j8E1HYSXY6j9FJqHODOYnEW8+SSggapDkQ_jBA@mail.gmail.com>
References: <CAHmME9pkktqOSUyTS_XhgC-CE4iqTv6UEA6w74kkm3xnBY8z9g@mail.gmail.com>
 <20170112091440.7f6cd41f@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:39223 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750971AbdALS2a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 13:28:30 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 3c8188a7
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 18:18:22 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id a768a05e (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Thu, 12 Jan 2017 18:18:21 +0000 (UTC)
Received: by mail-oi0-f51.google.com with SMTP id u143so32721374oif.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 10:28:22 -0800 (PST)
In-Reply-To: <20170112091440.7f6cd41f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 6:14 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> It is up to you but I doubt that code with new private ioctl's will be
> accepted upstream. If you want full review then post for inclusion upstream.
> If you just want to maintain it is a private fork, go ahead and do what
> you want and suffer the consequences.

Obviously I'm going for upstream conclusion and not willing to "suffer
the consequences", hence my email in the first place. Given that you
seem most interested in netlink, might you have any constructive
suggestions on how netlink might be used with very large atomic
messages?
