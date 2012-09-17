From: Ivan Minev <i.minev@comnet.bg>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Mon, 17 Sep 2012 14:20:25 +0000 (UTC)
Message-ID: <loom.20120917T161911-605@post.gmane.org>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120427134127.6d536a96@nehalam.linuxnetplumber.net> <20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:35506 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837Ab2IQPKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 11:10:01 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TDcxY-0007fB-40
	for netdev@vger.kernel.org; Mon, 17 Sep 2012 17:10:04 +0200
Received: from sofia-160.67.comnet.bg ([sofia-160.67.comnet.bg])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 17:10:04 +0200
Received: from i.minev by sofia-160.67.comnet.bg with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2012 17:10:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Still vlan don't work and have rx lenght errors chipset:88E8072 rev 10
