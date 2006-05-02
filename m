From: Ingo Oeser <netdev@axxeo.de>
Subject: [Bug 6480] Transmitter of CK804 hangs hard, needs power cycle to recover
Date: Tue, 2 May 2006 15:49:47 +0200
Message-ID: <200605021549.47719.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:20694 "EHLO mail.axxeo.de")
	by vger.kernel.org with ESMTP id S964820AbWEBNuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 May 2006 09:50:04 -0400
To: Manfred Spraul <manfred@colorfullife.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Manfred,

I filed BUG 6480 describing the problem and providing lots
of info. If you need more info, just ask.

At the moment I have no idea about the reasons.
Except Crossover-Cabling vs. using a switch.

The machine is a production machine, so I cannot test
kernels and patches. 

But I have several machines with identical hardware where
I can test this.

Once we can reproduce it without a Sonicwall, I can build a 
test setup using any kernel hackery required to resolve the issue :-)

Could you please contact the right nVIDIA people, if needed?

PS: Stephen, you are not CC'ed from bugzilla and 
      "agreed to help out with net driver maintenance" 
       so I CC'ed you here manually.

Regards

Ingo Oeser
