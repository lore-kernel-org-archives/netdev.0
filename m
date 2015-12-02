From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Increasing skb->mark size
Date: Wed, 2 Dec 2015 12:57:41 +0900
Message-ID: <CAKD1Yr0W-kgA_0kXmBJFa3_QPd6J294Dv07QcU424ujMNc6=Ng@mail.gmail.com>
References: <1448397144.14854.27.camel@mattb-dl> <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
 <87610ivv6u.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35597 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbbLBD6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 22:58:02 -0500
Received: by ykba77 with SMTP id a77so33124471ykb.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 19:58:01 -0800 (PST)
In-Reply-To: <87610ivv6u.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 4:13 AM, Andi Kleen <andi@firstfloor.org> wrote:
> This would be be great. I've recently ran into some issues with
> the overhead of the Android firewall setup.

Can you elaborate on which issues? If such a discussion would be
off-topic here, you can open a bug at
https://code.google.com/p/android/issues/list .
