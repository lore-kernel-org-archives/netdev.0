From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Mon, 21 Aug 2017 10:44:58 -0700
Message-ID: <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
         <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
         <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
         <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
         <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
         <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
         <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33184 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754000AbdHURpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:45:00 -0400
Received: by mail-pg0-f42.google.com with SMTP id t3so75693388pgt.0
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 10:45:00 -0700 (PDT)
In-Reply-To: <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 10:44 -0700, Eric Dumazet wrote:

> - Why is timewait not being used ?
> 

s/timewait/timestamps/
