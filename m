From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] net: Update RPS target at poll for inet
Date: Fri, 03 May 2013 15:06:42 -0700
Message-ID: <1367618802.22983.2.camel@edumazet-glaptop>
References: <20130501023452.E624181885@donbot.mtv.corp.google.com>
	 <CA+mtBx-HwJqbfCyWFvZswZEd6UwEr0Ee31a2uDGXL5rMeQ6sGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Majnemer <majnemer@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Paul Turner <pjt@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:36193 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab3ECWGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 18:06:45 -0400
Received: by mail-ia0-f171.google.com with SMTP id r13so1768788iar.16
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 15:06:45 -0700 (PDT)
In-Reply-To: <CA+mtBx-HwJqbfCyWFvZswZEd6UwEr0Ee31a2uDGXL5rMeQ6sGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-03 at 14:38 -0700, Tom Herbert wrote:
> I think this is nice idea, if someone is polling and then reading from
> another thread (CPU) that's not going to be good performance anyway.
> 
> Acked-by: Tom Herbert <therbert@google.com>
> 
> On Wed, Apr 17, 2013 at 1:10 PM, David Majnemer <majnemer@google.com> wrote:

David, netdev missed your mail because your mailer used a date in the
past.
