From: Jason Oster <parasytic@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Sat, 23 Mar 2013 12:17:29 -0700
Message-ID: <B0544E9D-BC59-449D-88A5-6DAFCB676F91@gmail.com>
References: <20111122.192338.1206677511966747729.davem@davemloft.net> <20111122183727.01ab6f04@telperion.jlyo.org> <1322059124.17693.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111123.172959.909786536317740314.davem@davemloft.net> <c873451a-71aa-418b-96e2-d8875e7fec3e@googlegroups.com> <1364057885.29473.4.camel@edumazet-glaptop>
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jlyo@jlyo.org, netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:32878 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab3CWTYy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 15:24:54 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so201179pad.40
        for <netdev@vger.kernel.org>; Sat, 23 Mar 2013 12:24:54 -0700 (PDT)
In-Reply-To: <1364057885.29473.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On Mar 23, 2013, at 9:58 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Hi Jay
> 
> Not reproducible on current kernels (net-next tree for example)

Thank you for looking into this so quickly! And it sounds like promising news, too. I'll experiment with newer kernels right away.

Thanks again,
Jay