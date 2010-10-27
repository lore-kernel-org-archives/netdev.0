From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Wed, 27 Oct 2010 09:48:05 +0000
Message-ID: <20101027094805.GA8929@ff.dom.local>
References: <1287125059.2659.1812.camel@edumazet-laptop> <20101015173746.12c7c40a.billfink@mindspring.com> <20101015220535.GA1997@del.dom.local> <20101016005106.35e4cc8d.billfink@mindspring.com> <20101016205824.GA2113@del.dom.local> <20101016212434.72ae5250.billfink@mindspring.com> <20101017203618.GA1889@del.dom.local> <20101019033724.0bffbe88.billfink@mindspring.com> <20101020110612.GA18315@ff.dom.local> <20101027005143.bfa8fbfd.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46496 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604Ab0J0JsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 05:48:13 -0400
Received: by bwz11 with SMTP id 11so343270bwz.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 02:48:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101027005143.bfa8fbfd.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 12:51:43AM -0400, Bill Fink wrote:
> On Wed, 20 Oct 2010, Jarek Poplawski wrote:
> > Btw, if you find time I would be interested in checking an opposite
> > concept of lower than real mtu (256) to use rate tables different way
> > (other tbf parameters without change). The patch below is needed for
> > this to work.
> 
> Sorry.  I'm totally swamped at work currently and won't be able
> to investigate that.

No problem, especially when current solution works for you.

Jarek P.
