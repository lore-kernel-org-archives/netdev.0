From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 12:32:37 +0000
Message-ID: <20090518123237.GC11162@ff.dom.local>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com> <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com> <20090515111227.7fc758cd@nehalam> <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com> <20090518104559.GA11162@ff.dom.local> <298f5c050905180527y52796deu191c16adef9548d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f115.google.com ([209.85.222.115]:54686 "EHLO
	mail-pz0-f115.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbZERMcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 08:32:53 -0400
Received: by pzk13 with SMTP id 13so1968260pzk.33
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 05:32:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905180527y52796deu191c16adef9548d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 01:27:08PM +0100, Antonio Almeida wrote:
> > Looks great! But, since HFSC uses rates directly (without rate tables)
> 
> This matter about the use of rate tables is not very familiar to me.
> In fact I keep wondering a lot of things about what kernel does with
> packets. Is there any documentation explaining how queue disciplines
> work and how it interacts with netfilter and tc_core? What about
> packets dispatching?

Here are a few links:
http://yesican.chsoft.biz/lartc/index.html

Jarek P.
