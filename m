From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.29.1: unregister_netdevice problem
Date: Fri, 8 May 2009 10:46:28 +0000
Message-ID: <20090508104628.GA6287@ff.dom.local>
References: <20090422055735.GA4334@night.netis.ru> <20090427054103.GA27529@night.netis.ru> <20090428125755.GA5242@night.netis.ru> <49F76BF6.4040709@gmail.com> <20090429054510.GA8267@night.netis.ru> <20090429090809.GA2995@ami.dom.local> <20090508062640.GA4555@night.netis.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alexander V. Lukyanov" <lav@netis.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:18160 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbZEHKqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 06:46:36 -0400
Content-Disposition: inline
In-Reply-To: <20090508062640.GA4555@night.netis.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 08, 2009 at 10:26:40AM +0400, Alexander V. Lukyanov wrote:
> On Wed, Apr 29, 2009 at 11:08:09AM +0200, Jarek Poplawski wrote:
> > So looks like a regression. Alas this thing could be hard to debug and
> > still more data is needed. For the beginning maybe: .config, dmesg,
> > and a few SysRq logs while this happens e.g. Alt-PrtScr with t, d, w, q
> > (gzipped or as attachments to a bugzilla report). (If it's not a big
> > problem trying 2.6.28.9 could be helpful too.)
> 
> It happened again with 2.6.29.2. Here is the requested info.

I can't see anything suspicious for now, except these UDP and TCP
warnings. Did you see similar messages with 2.6.27? Btw., could this
eth0.987 be "connected" with any of this traffic? (IP# ?)

Thanks,
Jarek P.
