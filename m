From: raviraj joshi <raviraj.j1991@gmail.com>
Subject: kenel level packet capturing
Date: Wed, 19 Oct 2011 12:24:01 +0530
Message-ID: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
References: <CAKj1SsP+GE=QqN8nx7aaAxXE8BODKb=vns_=SnbyySQjZp3-pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAKj1SsP+GE=QqN8nx7aaAxXE8BODKb=vns_=SnbyySQjZp3-pg@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We are making a kernel level packet capture module as a part of our BE project .
We are finding it difficult to understand kenel networking code.
We studied structures and functions like sk_buff, netif_rx(),dev_alloc_skb.

However we were not able to trace the actual path a simple packet follows.

Moreover we tried to count the no of times netif_rx function was
called it was much much lower than amount of packets actually being
received.

Can anyone please let us know the reason for this and how to approach
the problem of writing a kernel level packet capture module ,resoruces
we need to refer to (we are currently constrained to documents on
kernel-networking available online).

And even from where to get information about how forwarding(or packet
flow) occours when we have virtual bridges (in terms of networking
code).

regards,
Raviraj Joshi
PICT,Pune.
