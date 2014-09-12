From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of
 pkt_type_offset
Date: Fri, 12 Sep 2014 19:17:20 +0200
Message-ID: <1410542240.2970.5.camel@localhost>
References: <5412D9B9.2020300@redhat.com>
	 <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
	 <20140912160559.GA34038@its-macbook-pro.westell.com>
	 <CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
	 <1410541788.2970.2.camel@localhost>
	 <CAHA+R7PrM3EwqD_7nT8odoCqmk7Q8cCdEcUn9Ck0MVPZKW3VXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:55030 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751411AbaILRRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 13:17:24 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2AC8720BFC
	for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:17:23 -0400 (EDT)
In-Reply-To: <CAHA+R7PrM3EwqD_7nT8odoCqmk7Q8cCdEcUn9Ck0MVPZKW3VXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-09-12 at 10:12 -0700, Cong Wang wrote:
> On Fri, Sep 12, 2014 at 10:09 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> >
> > Sure, he asked me to send it and I included his signed-off. I think I
> > did that correctly?
> >
> 
> Maybe you should add v3 in case people like me get confused. :)

Oh, sorry. I looked in patchworks for the next version number and missed
the v2 submission. My bad, this should be submission v3. I think it is
ok, since the other versions already went out of review state.

Thanks for spotting,
Hannes
