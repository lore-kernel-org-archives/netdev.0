From: "John W. Linville" <linville@tuxdriver.com>
Subject: Wireless patches to push for 2.6.18?
Date: Fri, 26 May 2006 15:59:00 -0400
Message-ID: <20060526195855.GD32487@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:51723 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751408AbWEZT7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 15:59:07 -0400
Received: from bilbo.hq.tuxdriver.com (azure.tuxdriver.com [24.172.12.5])
	by ra.tuxdriver.com (8.13.6/8.13.6) with ESMTP id k4QJx0i8012537
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 26 May 2006 15:59:01 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k4QJx0h7010735
	for <netdev@vger.kernel.org>; Fri, 26 May 2006 15:59:00 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k4QJx0QF010733
	for netdev@vger.kernel.org; Fri, 26 May 2006 15:59:00 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As David M. so recently reminded us, 2.6.17 is likely to be blessed soon.
That will open a short merge window for non-"fixes" to go into 2.6.18.

Along w/ the patches currently on the 'upstream' branch, I'd like to
see some of the the drivers hanging-out only on the 'master' branch
of wireless-2.6 to get polished-up and pushed-out.  What do you think
are the best candidates?

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/master/

Anyone have anything else they are holding-back for 2.6.18?  What about
the wireless button infrastructure Ivo posted yesterday?  Is that
useful for any of the drivers currently in wireless-2.6?

I was caught a bit 'flat-footed' for the 2.6.17 merge window.
I'd like to be prepared for this one... :-)

Thanks!

John
-- 
John W. Linville
linville@tuxdriver.com
