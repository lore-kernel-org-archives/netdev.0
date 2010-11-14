From: Marcos <stalkingtime@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Sun, 14 Nov 2010 02:14:24 -0700
Message-ID: <AANLkTimkPpWob8ANySeWBvDE+Pq2wy4SQWJOSYzbS7QG@mail.gmail.com>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
	<AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
	<1289724643.2743.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Stephen Guerin <stephen@sfcomplex.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38563 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260Ab0KNJO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 04:14:26 -0500
Received: by bwz15 with SMTP id 15so4364308bwz.19
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 01:14:25 -0800 (PST)
In-Reply-To: <1289724643.2743.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have no idea why and how kademlia would be added to "linux kernel"
>
> Its a protocol based on UDP, and probably already done on userland.
>
> What am I missing ?

The idea is to tightly couple it to the operating system to create a
sort of "super operating system" that is seamless to the application
layers above.  Just like memory stores are tightly integrated as to be
unnoticeable....

marcos
