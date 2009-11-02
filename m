From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: HTB accuracy on 10GbE
Date: Mon, 02 Nov 2009 11:17:51 +0300
Message-ID: <4AEE95AF.7060605@bigtelecom.ru>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:44623 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918AbZKBIY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 03:24:26 -0500
In-Reply-To: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Also we planed convert 5-10 servers witch 1gigabit connection to one BIG server witch 10g (traffic rate in peak about 6gigabit) network card (Intel multiqueue).

Can test any patches for fix any problems in 10 gigabit connections!

Thanks!

JSC BIG Telecom

> Hi Stephen and all,
> 
> I have observed a HTB accuracy problem on the Linux kernel 2.6.30 and
> the Myri-10G 10 GbE NIC.
> HTB can control the transmission rate at Gigabit speed, however it can
> not work well at 10 Gigabit speed.
> 
> I asked Stephen this problem at Japan Linux Symposium.  He mentioned a
> HTB bug related to the timer granularity.
> I want to know what is happen, and what should be do for fixing it.
> 
> Any comments and suggestions will be welcome.
> 
> For more detail, please see the following page:
> http://code.google.com/p/pspacer/wiki/HTBon10GbE
> 
> Best regards,
> Ryousei
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

