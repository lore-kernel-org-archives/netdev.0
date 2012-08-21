From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: Re: IP fragmentation broken in 3.6-rc ?
Date: Tue, 21 Aug 2012 15:05:57 +0200
Message-ID: <CAF6-1L6DTXPGi4kbcPqbOXrrafMmZ6K1QdcAa=PxJBzZWkvojg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:34348 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274Ab2HUNF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 09:05:58 -0400
Received: by vcbfk26 with SMTP id fk26so6076180vcb.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 06:05:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm starting to wonder if it's not related to
46517008e1168dc926cf2c47d529efc07eca85c0 "ipv4: Kill
ip_rt_frag_needed()."

Cheers,

    Sylvain
