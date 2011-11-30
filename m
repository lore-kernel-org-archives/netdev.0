From: Markus Feldmann <feldmann_markus@gmx.de>
Subject: Re: Daughterboard Jetway JAD3RTLANG with three RTL-8110SC/8169SC
 Gigabit Ethernet is curious
Date: Wed, 30 Nov 2011 08:34:09 +0100
Message-ID: <jb4m9i$j5c$1@dough.gmane.org>
References: <jb0d7u$bbb$1@dough.gmane.org> <201111291012.25426.carsten@wolffcarsten.de> <4ED4E946.40209@gmx.de> <20111129230404.GB11127@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:43418 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873Ab1K3He2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 02:34:28 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RVegQ-0000Yg-8G
	for netdev@vger.kernel.org; Wed, 30 Nov 2011 08:34:22 +0100
Received: from dslb-092-076-246-128.pools.arcor-ip.net ([92.76.246.128])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:34:22 +0100
Received: from feldmann_markus by dslb-092-076-246-128.pools.arcor-ip.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 08:34:22 +0100
In-Reply-To: <20111129230404.GB11127@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 30.11.2011 00:04, schrieb Francois Romieu:
> Markus Feldmann<feldmann_markus@gmx.de>  :
> [...]
>> You mean the latest Linux kernel was patched for a better
>> initialization? At the moment i am using the kernel 3.0.8. As i
>> understood the firmware must be loaded at every power on.
>
> What do you mean ? Afaik there is no out-of-driver firmware for the
> (old) 8169sc.
>
> Can either of you or Carsten compare and send 'lspci -vv' before and
> after windows installs ?
>
Hi,

i have only Linux (Debian Squeeze/Stable), so i can only post my 
Linux-output:
http://pastebin.com/raw.php?i=YeELXqjP
Further on since yesterday, after my kernel upgrade to 3.1.4 i have no 
further problems. But i will wait some weeks.

regards Markus
