From: Franchoze Eric <franchoze@yandex.ru>
Subject: Re: RE: Re: Fwd: LVS on local node
Date: Fri, 23 Jul 2010 01:37:30 +0400
Message-ID: <188211279834651@web111.yandex.ru>
References: <20100723010102.121uPPJ1@mxfront8.mail.yandex.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, wensong@linux-vs.org,
	lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Graeme Fowler <graeme@graemef.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100723010102.121uPPJ1@mxfront8.mail.yandex.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



23.07.10, 01:01, "Graeme Fowler" <graeme@graemef.net>:

> Hi
>  
>  Technically keepalived is not LVS. It's a monitoring/mgmt app which can manage an LVS according to health-check logic. LVS by itself cannot "detect" any form of service failure - it's a fancy router with special rules.
>  
>  Graeme.
>  

Ah, ok. Then with iptables I can write keepalived app to insert/remove rules.
Is there interface to iptables for dynamically turn on/off rules without inserting and removing them from the table? 
