From: Hongmei Li <duckcncn@gmail.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Thu, 25 Sep 2014 22:24:43 +0000 (UTC)
Message-ID: <loom.20140926T001736-777@post.gmane.org>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org> <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com> <20140208172310.GF16198@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:35046 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbaIYWaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 18:30:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1XXHY3-0002nj-L7
	for netdev@vger.kernel.org; Fri, 26 Sep 2014 00:30:04 +0200
Received: from 144.189.31.3 ([144.189.31.3])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 00:30:03 +0200
Received: from duckcncn by 144.189.31.3 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 00:30:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes and Ben,

I encounter the same kernel panic.
Do you guys have any progress on this issue?

Thanks and Best Regards,
Hongmei
