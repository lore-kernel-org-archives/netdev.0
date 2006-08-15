From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Tue, 15 Aug 2006 15:08:36 +0300
Message-ID: <200608151508.36848.hasso@estpak.ee>
References: <20060814213718.580598840@postel.suug.ch> <20060815003614.GA8677@ms2.inr.ac.ru> <20060815111735.GU14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jamal <hadi@cyberus.ca>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from test.estpak.ee ([194.126.115.47]:13261 "EHLO devy.estpak.ee")
	by vger.kernel.org with ESMTP id S1752105AbWHOMIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 08:08:41 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060815111735.GU14627@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> However, I changed IPv4 addresses to provide the pid and support
> NLM_F_ECHO and the same will follow for IPv6 address notifications
> which will mean that quagga sees a different set of IPv4 address
> notifications.

Can you explain what exactly is changed?


-- 
Hasso Tepper
Elion Enterprises Ltd. [AS3249]
Data Communication Network Administrator
