From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: remove special ioctl from hso driver, replace by rfkill
Date: Wed, 16 Apr 2008 16:06:35 +0300
Message-ID: <4805F9DB.5030004@teltonika.lt>
References: <200804161428.18066.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:33932 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756313AbYDPNHN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 09:07:13 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Jm7Ls-0004Mg-M2
	for netdev@vger.kernel.org; Wed, 16 Apr 2008 13:07:04 +0000
Received: from 82-135-208-232.ip.zebra.lt ([82.135.208.232])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 13:07:04 +0000
Received: from paulius.zaleckas by 82-135-208-232.ip.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2008 13:07:04 +0000
In-Reply-To: <200804161428.18066.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> Hi,
> 
> could you test this patch?
> It does away with the one off serial ioctl replacing it with a standard
> mechanism.
> 

Can you describe me how can I test it? I am pretty new to rfkill :)
By looking at rfkill documentation I got impression that it will work
only on laptop... and I am using desktop PC.

Paulius

