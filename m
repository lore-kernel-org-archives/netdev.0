From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 11:16:08 +0200
Message-ID: <20070831091608.GD1772@ff.dom.local>
References: <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru> <20070831075909.GA1772@ff.dom.local> <46D7D072.5060508@bigtelecom.ru> <20070831090509.GC1772@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:57546 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757958AbXHaJOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 05:14:44 -0400
Content-Disposition: inline
In-Reply-To: <20070831090509.GC1772@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 11:05:09AM +0200, Jarek Poplawski wrote:
...
> So, maybe you would better try this, 'less testing', version of my patch:

Of course, the previous patch should be reverted (patch -p1 -R) or
clean 2.6.22.5 used for this.
 
Jarek P.
