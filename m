From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/3] [RFC] Implement multiqueue (RX & TX) virtio-net
Date: Fri, 4 Mar 2011 17:52:47 +0530
Message-ID: <OFBDB22C28.E6DB22A2-ON65257849.0043B15C-65257849.0043D8B3@in.ibm.com>
References: <20110228063427.24908.63561.sendpatchset@krkumar2.in.ibm.com> <1299178884.13202.50.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, arnd@arndb.de, avi@redhat.com,
	davem@davemloft.net, eric.dumazet@gmail.com, horms@verge.net.au,
	kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: habanero@linux.vnet.ibm.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1299178884.13202.50.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Theurer <habanero@linux.vnet.ibm.com> wrote on 03/04/2011 12:31:24
AM:

Hi Andrew,

> > _______________________________________________________________________
> >                 TCP: Guest -> Local Host (TCP_STREAM)
> >                  TCP: Local Host -> Guest (TCP_MAERTS)
> >             UDP: Local Host -> Guest (UDP_STREAM)
>
>
> Any reason why the tests don't include a guest-to-guest on same host, or
> on different hosts?  Seems like those would be a lot more common that
> guest-to/from-localhost.

This was missing in my test plan, but good point. I will run
these tests also and send the results soon.

Thanks,

- KK

