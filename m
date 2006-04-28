From: Gerhard de Jeger <gerhard.dejager@ss-online.co.za>
Subject: e1000 TX hang problems
Date: Fri, 28 Apr 2006 10:13:02 +0200
Message-ID: <1146211982.10106.7.camel@tux.co.za>
Reply-To: gerhard.dejager@ss-online.co.za
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vodamail.co.za ([196.11.146.148]:20158 "EHLO
	mx1.vodamail.co.za") by vger.kernel.org with ESMTP id S1030318AbWD1ILQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 04:11:16 -0400
Received: from localhost (localhost [127.0.0.1])
	by mx1.vodamail.co.za (Postfix) with ESMTP id 2F0C569561
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 10:11:15 +0200 (SAST)
Received: from mx1.vodamail.co.za ([127.0.0.1])
 by localhost (mx1.vodamail.co.za [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 22243-05 for <netdev@vger.kernel.org>;
 Fri, 28 Apr 2006 10:11:14 +0200 (SAST)
Received: from [10.54.36.117] (unknown [10.54.36.117])
	by mx1.vodamail.co.za (Postfix) with ESMTP id C7460696C2
	for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 10:11:13 +0200 (SAST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm also experiencing TX hang problems with the e1000 driver.

I was using the 6.0.60-k2 version previously which shipped with the
2.6.14.2 kernel.
 
I had no problems with this driver, but after my issues with the 7.0.33
driver I tried to go back to the 6.0.60-k driver. Now when I load the
module, there is an error saying that the EEPROM is corrupt - so I
cannot use the old driver which used to work.
 
Why is it that I now get the EEPROM error with the older driver?

Any ideas on how to fix the problem (with either the old driver or the
new one)?

Thanx,
Gerhard

