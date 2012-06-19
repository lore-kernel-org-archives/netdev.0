From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Tue, 19 Jun 2012 23:31:33 +0200
Message-ID: <1340141493.4604.773.camel@edumazet-glaptop>
References: <4FE0EA33.1000309@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:61775 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab2FSVbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 17:31:38 -0400
Received: by eeit10 with SMTP id t10so2199462eei.19
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2012 14:31:37 -0700 (PDT)
In-Reply-To: <4FE0EA33.1000309@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 23:08 +0200, Stefan Priebe wrote:
> Hello List,
> 
> i'm testing 10GBE speed with tweo servers. One with 3.5-rc3 nd thoe 
> other one whith RHEL 6 (2.6.32 kernel).
> 
> I noticed that setting
> net.ipv4.tcp_timestamps=0
> 
> descreased the performance from 9,7 Full Duplex to 3-4Gb/s.
> 
> Is this bahviour fine? What should / could i tet?
> 

Really, you should provide more input than that, if you really want us
to help.
