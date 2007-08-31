From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Fri, 31 Aug 2007 09:59:09 +0200
Message-ID: <20070831075909.GA1772@ff.dom.local>
References: <20070829113447.GA3575@ff.dom.local> <20070829121408.GB3575@ff.dom.local> <46D56C60.3060702@bigtelecom.ru> <20070829133042.GA4038@ff.dom.local> <20070830001632.ki4u5bx9sow40o4s@mail.himki.net> <20070830063110.GB1677@ff.dom.local> <20070830072718.GC1677@ff.dom.local> <46D68937.7030305@bigtelecom.ru> <20070830123751.GA2778@ff.dom.local> <46D7BD75.3080008@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:41080 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752936AbXHaH5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 03:57:45 -0400
Content-Disposition: inline
In-Reply-To: <46D7BD75.3080008@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 31, 2007 at 11:04:21AM +0400, Badalian Vyacheslav wrote:
> 
> I try you patch. Also i try add more debug options to kernel. I catch 
> (BUG: spinlock lockup on CPU#3, tc/6403, f742e200)
> All info in file. Ready for next patch ;)

I've to look at this, but actually my patch wrongly added this one
warning. I hope you did this on a testing machine...

Anyway there could be something new but I need some time. If possible,
2.6.23-rc4 should be the best thing for testing yet.

Thanks,
Jarek P.
