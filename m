From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 10:15:50 +0200
Message-ID: <20090531081550.GD2756@ami.dom.local>
References: <20090530114506.GA3166@ami.dom.local> <1243684594.3966.89.camel@dogo.mojatatu.com> <20090530120750.GB3166@ami.dom.local> <1243686683.3966.117.camel@dogo.mojatatu.com> <20090530124554.GC3166@ami.dom.local> <1243688628.3966.126.camel@dogo.mojatatu.com> <20090530132047.GD3166@ami.dom.local> <1243690297.3966.135.camel@dogo.mojatatu.com> <20090530140006.GE3166@ami.dom.local> <b10243b50905301538o2716855ag21fbc95b37c8da22@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Minoru Usui <usui@mxm.nes.nec.co.jp>,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: Minoru Usui <mi.usui@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:58508 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756789AbZEaIP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 04:15:56 -0400
Received: by fxm12 with SMTP id 12so5181929fxm.37
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 01:15:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b10243b50905301538o2716855ag21fbc95b37c8da22@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 31, 2009 at 07:38:51AM +0900, Minoru Usui wrote:
> Hi, jarek
Hi, Minoru
...
> I'm sorry, I don't investigate well, so I don't understand where
> unconfigured tp is destroyed, yet.
> If you don't mind, could you tell me where it's destoryed?

Just like configured ones, by deleting it or the whole tree.

Jarek P.
