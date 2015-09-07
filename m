From: Felix Kaiser <felix.kaiser@fxkr.net>
Subject: Re: [PATCH] ip link/addr show: add empty line between interfaces
Date: Mon, 07 Sep 2015 21:57:35 +0200
Message-ID: <1441653684-sup-9275@zero>
References: <1441537269-13899-1-git-send-email-felix.kaiser@fxkr.net> <20150907144609.3ec9f4d0@griffin> <1441639971-sup-8473@zero> <20150907175411.491f9c96@griffin> <20150907110932.7687a913@urahara>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jiri Benc <jbenc@redhat.com>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33876 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbIGT5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2015 15:57:38 -0400
Received: by wicfx3 with SMTP id fx3so98126759wic.1
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 12:57:37 -0700 (PDT)
In-reply-to: <20150907110932.7687a913@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Excerpts from Stephen Hemminger's message of 2015-09-07 11:09:32 -0700:
> Agreed with Jiri. I prefer the new shorter brief format, not longer format.

As long as it requires extra typing, few are going to use it.
It's about the default.

Did you try the brief format with a few v6 addresses on an
interface? When the line gets wrapped, it gets hard to read.

Besides, this isn't about the brief format, but about making
the long format less unreadable.

> Did you ever try a system with 10 interfaces or 1000 tunnels??

The largest I tried it on had 11 interfaces (8 of which are for tunnels).
That's not 1000, but how many people have that?

After all the positive feedback I got locally I'm genuinely
surprised that you don't like it, but I guess that's the way it is.

Thanks for looking at it, though!
Felix
