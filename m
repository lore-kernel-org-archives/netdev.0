From: David Miller <davem@davemloft.net>
Subject: Re: Fighting out-of-order reception with RPS?
Date: Tue, 14 Jul 2015 12:03:15 -0700 (PDT)
Message-ID: <20150714.120315.218180667705835403.davem@davemloft.net>
References: <1436763470.24939.66.camel@edumazet-glaptop2.roam.corp.google.com>
	<55A5424B.2000803@hartkopp.net>
	<CALx6S37TMbi0s4LK_j=VyZB0-vEHBWF4nFJsNSfQOz5D-Q0ksw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	sunil.kovvuri@gmail.com, jonathon.reinhart@gmail.com
To: tom@herbertland.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <CALx6S37TMbi0s4LK_j=VyZB0-vEHBWF4nFJsNSfQOz5D-Q0ksw@mail.gmail.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 14 Jul 2015 11:02:16 -0700

> then implement NAPI for CAN drivers as has been suggested now by
> three very experienced developers. This solves the your OOO problem
> and moves drivers to NAPI which is the greatly preferred interface.

+1

+1

+1
