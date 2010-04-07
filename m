From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] change dst_entry padding from using an array to using
 __attribute__
Date: Wed, 07 Apr 2010 18:56:32 +0200
Message-ID: <1270659392.8141.41.camel@edumazet-laptop>
References: <t2o97949e3e1004070946mfacef7c0la6bddc38d29720ae@mail.gmail.com>
	 <1270659329.8141.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:60852 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758117Ab0DGQ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 12:56:37 -0400
Received: by bwz1 with SMTP id 1so1026785bwz.21
        for <netdev@vger.kernel.org>; Wed, 07 Apr 2010 09:56:36 -0700 (PDT)
In-Reply-To: <1270659329.8141.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 avril 2010 =C3=A0 18:55 +0200, Eric Dumazet a =C3=A9crit=
 :

> We dont want a huge hole (say.. 120 bytes) being not noticed.

sorry, 60 bytes of course.


