From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 10:12:38 -0700
Message-ID: <CAHA+R7PrM3EwqD_7nT8odoCqmk7Q8cCdEcUn9Ck0MVPZKW3VXw@mail.gmail.com>
References: <5412D9B9.2020300@redhat.com>
	<3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
	<20140912160559.GA34038@its-macbook-pro.westell.com>
	<CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
	<1410541788.2970.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:64797 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbaILRMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 13:12:39 -0400
Received: by mail-lb0-f180.google.com with SMTP id b12so1282150lbj.25
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 10:12:38 -0700 (PDT)
In-Reply-To: <1410541788.2970.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 10:09 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> Sure, he asked me to send it and I included his signed-off. I think I
> did that correctly?
>

Maybe you should add v3 in case people like me get confused. :)
