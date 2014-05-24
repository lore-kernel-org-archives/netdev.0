From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Sat, 24 May 2014 07:58:15 -0400
Message-ID: <53808957.7020906@mojatatu.com>
References: <6zlhtsvnqp.fsf@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonas Bonn <jonas@southpole.se>
To: =?UTF-8?B?TmllbHMgTcO2bGxlcg==?= <nisse@southpole.se>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:54192 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbaEXL6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 07:58:23 -0400
Received: by mail-ig0-f170.google.com with SMTP id uy17so1791716igb.3
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 04:58:22 -0700 (PDT)
In-Reply-To: <6zlhtsvnqp.fsf@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/14 05:38, Niels M=C3=B6ller wrote:
> Hi,
>


>     Main drawback of using NAT is the overhead for connection trackin=
g;
>     it would be preferable if the only per-connection state needed is=
 the
>     socket itself.
>

If stateless nat is sufficient take a look at tc nat.

cheers,
jamal
