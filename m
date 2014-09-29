From: Hongmei Li <duckcncn@gmail.com>
Subject: Re: IPv6 FIB related crash with MACVLANs in 3.9.11+ kernel.
Date: Mon, 29 Sep 2014 18:15:11 +0000 (UTC)
Message-ID: <loom.20140929T195637-887@post.gmane.org>
References: <52EFFE20.5080500@candelatech.com> <20140203220323.GB17999@order.stressinduktion.org> <52F012FF.9030105@candelatech.com> <52F65EB4.1050306@candelatech.com> <20140208172310.GF16198@order.stressinduktion.org> <loom.20140926T001736-777@post.gmane.org> <1411906297.2400343.172598909.66223582@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:58106 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752481AbaI2SP1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 14:15:27 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1XYfTp-0007DI-CE
	for netdev@vger.kernel.org; Mon, 29 Sep 2014 20:15:25 +0200
Received: from 144.189.31.3 ([144.189.31.3])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 20:15:25 +0200
Received: from duckcncn by 144.189.31.3 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 20:15:25 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Hannes for your prompt response!

We just encountered this issue two times in our product stability test so far,
and my panic backtrace is the exactly same with the one reported here.
I don't know how to reproduce the issue till now. 
I tried several method, unfortunately, I can not reproduce it by myself. :(

Thanks,
Hongmei
