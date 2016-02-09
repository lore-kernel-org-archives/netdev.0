From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 2/4] net: add rx_nohandler stat counter
Date: Tue, 09 Feb 2016 03:40:23 -0500 (EST)
Message-ID: <20160209.034023.50018877443465909.davem@davemloft.net>
References: <20160208183254.GB4566@redhat.com>
	<20160208113821.0ba26eb0@xeon-e3>
	<1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jarod@redhat.com,
	linux-kernel@vger.kernel.org, edumazet@google.com,
	jiri@mellanox.com, daniel@iogearbox.net, tom@herbertland.com,
	j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454972260.7627.368.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Feb 2016 14:57:40 -0800

> Whole point of TLV is that it allows us to add new fields at the end of
> the structures.
 ...
> Look at iproute2, you were the one adding in 2004 code to cope with
> various tcp_info sizes.
> 
> So 12 years later, you cannot say it does not work anymore.

+1
