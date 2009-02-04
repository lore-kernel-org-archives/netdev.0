From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [RESEND] iproute2 : invalid burst/cburst calculation
	with hrtimers
Date: Wed, 4 Feb 2009 23:49:29 +0100
Message-ID: <20090204224929.GB2828@ami.dom.local>
References: <200902021926.17768.denys@visp.net.lb> <498A0699.6020103@gmail.com> <498A0E4A.8050807@gmail.com> <200902050026.46603.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:15045 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756821AbZBDWr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 17:47:26 -0500
Received: by fk-out-0910.google.com with SMTP id f33so2269515fkf.5
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2009 14:47:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200902050026.46603.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 12:26:46AM +0200, Denys Fedoryschenko wrote:
...
> Maybe we can put note in documentation or even htb help output, that user can 
> increase precision with hrtimers enabled, by setting HZ variable?

Hmm... I rather meant using burst and cburst params. But hrtimers are
very hardware dependent, so it's hard to advise anything.

Jarek P.
