From: jamal <hadi@cyberus.ca>
Subject: Re: libpcap and tc filters
Date: Tue, 05 Jul 2011 06:56:43 -0400
Message-ID: <1309863403.1765.0.camel@mojatatu>
References: <CAA0qwj6fWJFVCDW9M9jZhvQnSTy=Pnyp0AhWFYT8FOiroq7C=Q@mail.gmail.com>
	 <1309777908.26180.1.camel@mojatatu>
	 <CAA0qwj70-qUQ+6NL=2LP05TyMN99MdL1BF8tko+v=DhdyjZjJQ@mail.gmail.com>
	 <CAA0qwj7cH8Ah69fBMkXpGkwG77TH_ZqMhKwj-Cc8Vc=F5c9SSw@mail.gmail.com>
	 <1309784740.26180.21.camel@mojatatu>
	 <CAA0qwj4=bOU3LDsRk591AtBWx2c_6uFwk0M4-AGrnxCPKjbbrw@mail.gmail.com>
	 <1309788416.26180.63.camel@mojatatu>
	 <CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Adam Katz <adamkatz0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34600 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab1GEK4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 06:56:48 -0400
Received: by iyb12 with SMTP id 12so5090808iyb.19
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2011 03:56:47 -0700 (PDT)
In-Reply-To: <CAA0qwj4FUpfdux73WCxFcjX0xp-zNtMwncRRmN7ea1Kr9FX3Kw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-07-04 at 17:16 +0300, Adam Katz wrote:
> thanks a lot
> I can tell you I'm not the first one to have this problem, but it
> doesn't seem to be common... but that's probably because people
> usually don't try to shape traffic sent using libpcap.
> 
> I found this post from 2003 on lartc with the exact same problem but
> with no replies:
> http://mailman.ds9a.nl/pipermail/lartc/2003q4/011004.html

I downloaded tcpreplay and reproduced the issue with your rules.
Will look into it..

cheers,
jamal

