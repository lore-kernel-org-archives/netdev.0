From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/3] bonding: rcu cleanups
Date: Tue, 15 Jul 2014 13:51:52 +0200
Message-ID: <1405425112.10255.31.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1405417604-7828-1-git-send-email-edumazet@google.com>
	 <53C50897.2020605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:39136 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758321AbaGOLv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 07:51:58 -0400
Received: by mail-we0-f173.google.com with SMTP id q58so518325wes.4
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 04:51:57 -0700 (PDT)
In-Reply-To: <53C50897.2020605@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-07-15 at 12:55 +0200, Nikolay Aleksandrov wrote:
> Nice clean up, I also gave it a quick run. I believe similar clean up would
> be beneficial for current_arp_slave at some point.

Yes this one should be much easier, I'll send it, thanks.
