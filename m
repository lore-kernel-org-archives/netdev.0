From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 16:15:01 -0700
Message-ID: <CAB=NE6X-v+XqSr4AiyRp1og0AmYK1yFq7Oro8UZxWRdgWXDu2g@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
 <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
 <CAB=NE6XrkdiZcGEDGuYe=SwLBhTm=Mt4NaPzjV9j_W-8sVosOA@mail.gmail.com>
 <CAA93jw5pTHpUOX=iUnck8Eun2iNqkuKwG-Jd0X1oNxD_s9_prA@mail.gmail.com>
 <CAB=NE6V7jFgtK4HmkUnfY5MuWCJoTyo83p9KMVTvmXTsrGoTew@mail.gmail.com> <CAA93jw6Ude=x=5v2cq86UjnORXDhAQASp51zLvDDBYHB28T_Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:41104 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755259Ab1H2XPW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 19:15:22 -0400
In-Reply-To: <CAA93jw6Ude=x=5v2cq86UjnORXDhAQASp51zLvDDBYHB28T_Jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2011 at 4:10 PM, Dave Taht <dave.taht@gmail.com> wrote:
> My goal in collecting these recordings is to get TRANSCRIPTS of what
> is important and what is not, so that ultimately better documentation
> can be written from those than exist today.
>
> Since the byte queuing issue is hot this week, I decided to make more
> people aware that these recordings existed in the hope that more
> available background information on how wireless works could be
> internalized by more people.
>
> I did note that the talk with felix was an attempt at capturing and
> summarizing some bufferbloat history and only towards the end did we
> start moving forward to things we planned to try, while the talk with
> andrew was an attempt at doing a more technical overview of quite a
> few issues.
>
> Multiple people have found these conversations useful. Certainly I
> find them useful, often reviewing them a few weeks after the fact to
> find subtleties that I missed originally, or needed further reading t=
o
> really understand or write code for. The earliest conversation I had
> with felix (march?) still has some useful nuggets in it about how
> aggregation actually works that I hope to mine one day for better
> documentation. It also had some glaring errors in it...
> (mostly MINE!)
>
> http://mirrors.bufferbloat.net/podcasts/
>
> I would certainly like to have a (recorded!) conversation with you to
> have a constructive
> discussion of the issues you find important, correct, and essential,
> towards making wireless networking better.
>
> Many people are capable of doing otherwise useful work while having a
> podcast running in the background that might have a few percentage
> points of useful information.
>
> By all means, don't listen if you can't split the brain cells, as I
> wrote I will have transcript of that latest available and will try to
> summarize and extract the best of what was discussed, after we get
> some code written and some tests performed.
>
> =C2=A0There are many other folk I would like to interview in this way=
, as well.

Honestly I do not have > 1 hour to review random audio on some topic
when the only meat of what I want is in 5 minutes of the > 1 hour
talk; the reason I stuck to hearing most of the talk though is I am
quite tired of the FUD around bufferbloat and also tired of the random
adhoc patches, e-mails and rants about it. My recommendation is edit
crap out and make a more condensed clip with the stuff technical folks
really care about. I'm not saying no one will find it useful, I'm
saying technical folks will puke all over it and likely not want to
even review more bufferbloat crap later. That's where I'm at least.

  Luis
