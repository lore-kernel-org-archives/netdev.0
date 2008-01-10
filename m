From: "Andy Johnson" <johnsonzjo@gmail.com>
Subject: ipip tunnel code (IPV4)
Date: Thu, 10 Jan 2008 16:34:34 +0200
Message-ID: <147a89290801100634t7854a101w203de150982b0284@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:11724 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922AbYAJOeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 09:34:36 -0500
Received: by fg-out-1718.google.com with SMTP id e21so711022fga.17
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 06:34:34 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I am trying to learn the IPV4 ipip tunnel code  (net/ipv4/ipip.c)
and I have two little questions about
semantics of variables:

ipip_fb_tunnel_init - what does "fb" stand for ?

In tunnels_wc   : what does "wc" stand for ?

Regards,
Andy
