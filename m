From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Who's allowed to set a skb destructor?
Date: Fri, 6 Jul 2007 11:44:03 +0200
Message-ID: <20070706094403.GC2362@ff.dom.local>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local> <20070705122847.GA13368@2ka.mipt.ru> <20070706090835.GB2362@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Brice Goglin <Brice.Goglin@ens-lyon.org>,
	netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:37608 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759626AbXGFJfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 05:35:33 -0400
Content-Disposition: inline
In-Reply-To: <20070706090835.GB2362@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 06, 2007 at 11:08:35AM +0200, Jarek Poplawski wrote:
...
> BSDs were sometimes recommended for specific jobs like mail etc.
> but usually linux better fitted the needs. Especially well linux
> appeared for an internet gateway/router/firewall/antispam thing,
> and the main reasons were: netfilter with additional, unofficial
> patches e.g. l-7 filtering and imq. BSD was no option here.

I've forgotten to mention two other "performance boosters" which
very often completed these solutions: htb or hfsc.

Jarek P.
