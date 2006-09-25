From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: kernel: TKIP: replay detected:
Date: Mon, 25 Sep 2006 10:50:00 -0400
Message-ID: <20060925144954.GC16949@tuxdriver.com>
References: <20060924104053.GA6645@frodo.home.lxtec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:47885 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750712AbWIYOuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 10:50:19 -0400
Received: from bilbo.hq.tuxdriver.com ([70.61.120.53])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id k8PEnAtX024523
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 10:49:16 -0400
Received: from bilbo.hq.tuxdriver.com (localhost.localdomain [127.0.0.1])
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1) with ESMTP id k8PEo1pF029357
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 10:50:01 -0400
Received: (from linville@localhost)
	by bilbo.hq.tuxdriver.com (8.13.1/8.13.1/Submit) id k8PEo0VM029356
	for netdev@vger.kernel.org; Mon, 25 Sep 2006 10:50:00 -0400
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20060924104053.GA6645@frodo.home.lxtec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 24, 2006 at 12:40:53PM +0200, Elimar Riesebieter wrote:

> My sylog is filled up with thousands of:
> Sep 21 18:18:00 aragorn kernel: TKIP: replay detected: \
> STA=XX:XX:BB:LL:KK:00 previous TSC 00000000BLAa received TSC 00000000BLAa
> Sep 21 18:18:29 aragorn kernel: printk: 62 messages suppressed.

Opinion seems to be running that these messages are useless and should
be removed.  Anyone disagree?

Anybody want to send a patch?

John
-- 
John W. Linville
linville@tuxdriver.com
