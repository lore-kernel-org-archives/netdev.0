From: Esteban Lopez <elopez@softel.net.mx>
Subject: Re: unmanaged L2TPv3 ethernet pseudowire Cisco <=> Linux
Date: Tue, 29 Apr 2014 17:49:54 +0000 (UTC)
Message-ID: <loom.20140429T194743-326@post.gmane.org>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se> <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com> <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se> <51535D16.4080207@katalix.com> <loom.20131021T165114-650@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59182 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932491AbaD2RzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 13:55:08 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1WfCFD-0000Ry-LW
	for netdev@vger.kernel.org; Tue, 29 Apr 2014 19:55:04 +0200
Received: from dsl-187-195-7-78-dyn.prod-infinitum.com.mx ([dsl-187-195-7-78-dyn.prod-infinitum.com.mx])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 19:55:03 +0200
Received: from elopez by dsl-187-195-7-78-dyn.prod-infinitum.com.mx with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 19:55:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi 

I'm trying to create a l2tpv3 tunnel between linux box (kernel 2.6.38) and 
Cisco.

I compiled the James's patch but when I try to use "encap ip" I receive this 
error:

RTNETLINK answers: Protocol not supported

I test the same in with kernel 3.2.0 but I have the same output.

Anybody know if I have a kernel's opction missed?

Thank you in advance!
