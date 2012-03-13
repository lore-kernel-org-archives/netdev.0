From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Tue, 13 Mar 2012 12:52:42 -0400
Message-ID: <CADVnQy=U3rZM7NUWEGrNaRjAj4vUM+2chyucRXhnswx2UCzxGA@mail.gmail.com>
References: <20120310122725.GA31129@hostway.ca>
	<1331401490.2453.28.camel@edumazet-laptop>
	<1331402182.2453.30.camel@edumazet-laptop>
	<1331407221.2453.42.camel@edumazet-laptop>
	<20120313072643.GA32306@hostway.ca>
	<20120313140737.GA1424@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Kirby <sim@netnation.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fa0-f46.google.com ([209.85.161.46]:61677 "EHLO
	mail-fa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757506Ab2CMQ6i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 12:58:38 -0400
Received: by faas1 with SMTP id s1so214764faa.19
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 09:58:36 -0700 (PDT)
In-Reply-To: <20120313140737.GA1424@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 13, 2012 at 10:07 AM, Dave Jones <davej@redhat.com> wrote:
> On Tue, Mar 13, 2012 at 12:26:44AM -0700, Simon Kirby wrote:
>
> =A0> Oops two seconds later, scrolled off console, didn't get written=
 to disk
> =A0> or remote syslog server, all we have is syslog-broadcasted Oops =
and Code
> =A0> lines due to broken printk priorities:
>
> I posted two reports we've had against Fedora yesterday which look li=
ke this bug.
>
> https://bugzilla.redhat.com/show_bug.cgi?id=3D801599
> https://bugzilla.redhat.com/show_bug.cgi?id=3D802660

Yes, these look like the same issue.

neal
