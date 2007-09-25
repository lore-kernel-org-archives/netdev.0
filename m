From: "Robert Iakobashvili" <coroberti@gmail.com>
Subject: Re: Userspace network stack and netchannels.
Date: Tue, 25 Sep 2007 21:22:47 +0200
Message-ID: <7e63f56c0709251222q608488c8wba05eb5a06ee3e32@mail.gmail.com>
References: <20070925180043.GA16698@2ka.mipt.ru>
	 <7e63f56c0709251220s12ab10b5pade5b2c90fa4a8b9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:22846 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbXIYTWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 15:22:48 -0400
Received: by py-out-1112.google.com with SMTP id u77so3719516pyb
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2007 12:22:47 -0700 (PDT)
In-Reply-To: <7e63f56c0709251220s12ab10b5pade5b2c90fa4a8b9@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

On 9/25/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
>  I've released new version of the extremely small
> userspace netowork stack [1] implementation.
>

>  1. Userspace network stack.
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=unetstack
>
> 2. Netchannel subsystem.
>  http://tservice.net.ru/~s0mbre/old/?section=projects&item=netchannel
>
> 3. Gigabit send/recv benchmark for netchannels and sockets using small
> packets.
> http://tservice.net.ru/~s0mbre/blog/devel/networking/2006_10_26.html
>  http://tservice.net.ru/~s0mbre/blog/devel/networking/2006_12_21.html
>

Very interesting. Are there any details of your benchmarking available,
namely, how it was done?
Have you some comparison profiling data (oprofile) to figure out where
the advantages are coming from?

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
 http://curl-loader.sourceforge.net
A web testing and traffic generation tool.

-- 
Sincerely,
Robert Iakobashvili,
coroberti %x40 gmail %x2e com
...........................................................
http://curl-loader.sourceforge.net
A web testing and traffic generation tool.
