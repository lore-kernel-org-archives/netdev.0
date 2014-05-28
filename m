From: sowmini varadhan <sowmini05@gmail.com>
Subject: Re: Scaling 'ip addr add' (was Re: What's the right way to use a
 *large* number of source addresses?)
Date: Wed, 28 May 2014 06:01:07 -0400
Message-ID: <CACP96tRo1OthQqDhPLVgai2vJPkd6macpdkD3MKwePZa8GMUnQ@mail.gmail.com>
References: <CACP96tRSpop=Sf58qE6TXeF+a-5nqfCj5d12bwD9WaYue_6_UA@mail.gmail.com>
	<1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	=?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	netdev <netdev@vger.kernel.org>, Jonas Bonn <jonas@southpole.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:57420 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaE1KBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 06:01:09 -0400
Received: by mail-la0-f45.google.com with SMTP id gl10so7294028lab.32
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 03:01:07 -0700 (PDT)
In-Reply-To: <1401241268.5367.266.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You did not provide kernel version you used.
>
> Last time I checked, we were spending _lot_ of time in check_lifetime()
>
> ( this stuff was added in linux-3.9 )
>

Built the latest kernel (vmlinuz-3.15.0-rc6+) from a clone
of kernel.git from may 24

--Sowmini
