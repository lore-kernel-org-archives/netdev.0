From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] core: adjust checks for calling skb_copy_bits
 in skb_try_coalesce
Date: Thu, 20 Sep 2012 09:00:33 +0200
Message-ID: <1348124433.31352.64.camel@edumazet-glaptop>
References: <1348111182-6827-1-git-send-email-roy.qing.li@gmail.com>
	 <1348118417.31352.52.camel@edumazet-glaptop>
	 <CAJFZqHzTEwgJaKjvNLW3yYbMLUu0xm8tHwQ2e_TZJNdiTKOTFw@mail.gmail.com>
	 <1348120438.31352.63.camel@edumazet-glaptop>
	 <CAJFZqHz5Ny8kbXk4arj-CEfQs+r28oGUQChNJ+0nSOTTg=c82A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:55106 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136Ab2ITHAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 03:00:37 -0400
Received: by bkwj10 with SMTP id j10so938593bkw.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 00:00:36 -0700 (PDT)
In-Reply-To: <CAJFZqHz5Ny8kbXk4arj-CEfQs+r28oGUQChNJ+0nSOTTg=c82A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 13:57 +0800, RongQing Li wrote:

> 
> I am wrong, thanks.

Thanks for taking a look at this stuff ;)
