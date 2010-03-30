From: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Subject: Re: UDP path MTU discovery
Date: Wed, 31 Mar 2010 00:04:51 +0200
Message-ID: <20100330220450.GA14304@laped.iglesias.mooo.com>
References: <20100329201431.GH20695@one.firstfloor.org>
 <20100329205035.GA32656@laped.iglesias.mooo.com>
 <4BB11510.9000302@hp.com>
 <1269898152.1958.86.camel@edumazet-laptop>
 <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com>
 <20100330052044.GJ20695@one.firstfloor.org>
 <20100330061627.GA22436@laped.iglesias.mooo.com>
 <20100330061952.GO20695@one.firstfloor.org>
 <20100330082013.GA18300@edde.se.axis.com>
 <20100330141237.GP20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:55952 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883Ab0C3WE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 18:04:57 -0400
Received: by ewy20 with SMTP id 20so1701345ewy.1
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 15:04:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100330141237.GP20695@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 30, 2010 at 04:12:37PM +0200, Andi Kleen wrote:
> > Where does the application controllable per socket MTU come into the
> > picture?
> 
> To set the minimum path MTU so that there is a guarantee that IPv6 routers
> (which are unable to fragment themselves) will never drop it.

Not sure I agree with that kind of solution but thats probably
because of missunderstandings on my side :)

Thanks for explaning.
