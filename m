From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: bridge not learning from locally sent gratuitous ARP?
Date: Thu, 21 Apr 2016 20:58:37 +0900
Message-ID: <5718C06D.8080900@lab.ntt.co.jp>
References: <CAJ26g5SKzs=+0MmanfC4Hfuti_jLo5R=e6T6imNc98rXVsA1ug@mail.gmail.com>
 <5718AC0A.8090009@lab.ntt.co.jp>
 <CAJ26g5T65eXWBQBZzRb=hzr+29dUUnWxfN=GUu=ouQJVKZiVGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick Schaaf <netdev@bof.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:55609 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbcDUL6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 07:58:54 -0400
In-Reply-To: <CAJ26g5T65eXWBQBZzRb=hzr+29dUUnWxfN=GUu=ouQJVKZiVGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So, assuming that proives stable, I have a workaround - but one that
> needs knowlege of A) the unterlying interface (brport) to fondle, and
> B) the macvlan MAC address that needs adding. keepalived couldn't
> easily do that "in code" because it does not know what sits under the
> bridge.
> 
> Naive question: shouldn't that work automatically, i.e. macvlan when
> sitting on to of a bridge, doing that internally?

I'll think of this, thank you.

Toshiaki Makita
