From: Sergey Kaydalov <kayserg@gmail.com>
Subject: Re: SMSC9215 Issue
Date: Wed, 29 May 2013 18:40:54 +0000 (UTC)
Message-ID: <loom.20130529T203633-104@post.gmane.org>
References: <5D308BD40154E4439D82454FE483A50205BB46AD@EVS4.nam.ci.root>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:46012 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757319Ab3E2SpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 14:45:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UhlMt-0003ar-B2
	for netdev@vger.kernel.org; Wed, 29 May 2013 20:45:03 +0200
Received: from nat150.iteam.ua ([194.146.132.150])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 20:45:03 +0200
Received: from kayserg by nat150.iteam.ua with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 20:45:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bishop, Mark <Mark.Bishop <at> cooperindustries.com> writes:

> 
> I am having an issue interfacing my uClinux platform with a SMSC9215.
> 
> The part doesn't have link with the Micrel KSZ8995 it is attached too
> before it tries to execute smsc911x_phy_check_loopbackpkt() in
> smsc911x.x  
>  
Hello, Bishop!
I got very similar problem with LAN9221 connected to am3359 MCU. uboot work 
well, but kernel gives me output exactly like you got. Have you managed to 
solve the problem?
