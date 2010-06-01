From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: Fore 200 firmware
Date: Tue, 01 Jun 2010 10:37:51 -0400
Message-ID: <201006011437.o51Ebp6f014332@thirdoffive.cmf.nrl.navy.mil>
References: <alpine.SOC.1.00.1005311058180.2805@math.ut.ee>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:51600 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135Ab0FAOiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 10:38:21 -0400
In-reply-to: <alpine.SOC.1.00.1005311058180.2805@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <alpine.SOC.1.00.1005311058180.2805@math.ut.ee>,Meelis Roos writes:
>So the current state is that drivers/atm contains the C dump of fore 200 
>firmware in drivers/atm/fore200e_pca_fw.c but this firmware is not built 
>and not installed by make install. It's also not present in 
>linux-firware tree/packages so the fore driver can not load its firmware 
>from anywhere. I guess this is not the intended outcome.

this firmware is in the linux-atm source tree now.  the 2.5.1 release
should have the firmware.

http://sourceforge.net/projects/linux-atm/files/
