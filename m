From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Tue, 20 Jan 2015 12:43:32 +0100
Message-ID: <CAPh34mejiAe6zgM+VtSTGgjJir7CK8wP9AufsXgz1rQ7-_skvQ@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
	<CAPh34mdi+8wLaUY3ZBks40wbOtdzsbTrmuvsHivRouc9rs3gig@mail.gmail.com>
	<54BE392F.2070804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:57754 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbbATLnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 06:43:35 -0500
Received: by mail-la0-f45.google.com with SMTP id gd6so10032455lab.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 03:43:33 -0800 (PST)
In-Reply-To: <54BE392F.2070804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 January 2015 at 12:17, Daniel Borkmann <dborkman@redhat.com> wrote:

> I have no strong opinion on this, but I also have a limited view on
> what applications try to parse ss output in general.
>
> As mentioned, for human readability, we should implement a top-like
> display option which is allowed to have a rather 'instable' output
> by nature and levels of detail can be folded/unfolded on demand.

+1 on that.

> Given the recent discussion on web10g, json output option might
> be very useful to provide i.e. when stats are being further extended.

Ok, there seems conses on JSON output.

Stephan, what do you think?
