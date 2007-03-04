From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Sun, 4 Mar 2007 02:02:36 -0800
Message-ID: <f2b55d220703040202y7d6e5c72q8b5c8fd3d11fd06a@mail.gmail.com>
References: <20070204074143.26312.qmail@science.horizon.com>
	 <20070217131302.GA22732@2ka.mipt.ru>
	 <20070302085246.GA30951@2ka.mipt.ru>
	 <200703021056.24100.dada1@cosmosbay.com>
	 <f2b55d220703021245m5cd5d9eet5e5a9d0d8ffcea41@mail.gmail.com>
	 <20070303104620.GD22557@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:22569 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527AbXCDKCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 05:02:43 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1251235wxd
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2007 02:02:42 -0800 (PST)
In-Reply-To: <20070303104620.GD22557@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/3/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Btw, you could try to implement something you have written above to show
> its merits, so that it would not be an empty words :)

Before I implement, I design.  Before I design, I analyze.  Before I
analyze, I prototype.  Before I prototype, I gather requirements.
Before I gather requirements, I think -- and the only way I know how
to think about technical matters is to write down my intuitions and
compare them against the sea of published research on the topic.  I'm
only partway through thinking about RCU and DDoS, especially as this
is on the fringe of my professional expertise and the appropriate
literature is not currently at my fingertips.

The only times that I make exceptions to the above sequence are 1,
when someone is paying me well to do so (usually to retrofit some kind
of sanity onto a pile of crap someone else wrote) and 2, when I really
feel like it.  At present neither exception applies here, although I
may yet get so het up about threadlets that I go into a coding binge
(which may or may not produce an RCU splay tree as a side effect).  I
wouldn't hold my breath if I were you, though; it's the first of what
promises to be a string of fine weekends, and if I binge on anything
this spring it's likely to be gardening.

Cheers,
- Michael
