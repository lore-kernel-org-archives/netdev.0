From: Mohan Reddy <mohanreddykv@gmail.com>
Subject: Help On function to get IPV6 address of an interface in kernel
Date: Thu, 4 Mar 2010 15:11:04 +0530
Message-ID: <20100304094103.GA6599@mohan-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:38092 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434Ab0CDJlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 04:41:22 -0500
Received: by gwb15 with SMTP id 15so1144335gwb.19
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 01:41:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Is there a function or a way in kernel to get an interface ipv6 address if interface name or net_device object is known? I searched in the kernel i got a function ipv6_get_ifaddr(). But it is expecting an ipv6 address as a parameter. 

Thanks for your help in advance.

-Mohan Reddy 
