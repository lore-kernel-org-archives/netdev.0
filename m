From: Giuseppe Cavallaro <peppe.cavallaro@gmail.com>
Subject: Info about the GSO support
Date: Fri, 26 Jan 2007 10:58:32 +0000 (UTC)
Message-ID: <loom.20070126T115104-743@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52588 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965615AbXAZMUK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 07:20:10 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HAQ3m-0001rT-53
	for netdev@vger.kernel.org; Fri, 26 Jan 2007 13:20:02 +0100
Received: from cps2.dmz-eu.st.com ([164.129.1.42])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 13:20:02 +0100
Received: from peppe.cavallaro by cps2.dmz-eu.st.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 26 Jan 2007 13:20:02 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I=E2=80=99m working on an embedded network interface (core by Synopsys)=
 and I=E2=80=99ve already
written my first Linux network device driver.
My hardware has an internal DMA so I=E2=80=99ve used the scatter gather=
 implementation.
Moreover, this HW doesn=E2=80=99t support the TSO feature.=20
I=E2=80=99m wondering if I can use the new GSO as well.=20
=46inally, I=E2=80=99ve a kernel 2.6.17.14; where can I get the GSO pat=
ches for this
kernel version?
Thanks a lot
Regards
Giuseppe

