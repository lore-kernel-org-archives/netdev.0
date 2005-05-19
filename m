From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 11:49:01 -0700 (PDT)
Message-ID: <20050519.114901.108984882.davem@davemloft.net>
References: <Xine.LNX.4.44.0505190915010.15522-100000@thoron.boston.redhat.com>
	<1116510411.6240.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, akpm@osdl.org, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com, johnpol@2ka.mipt.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1116510411.6240.54.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 19 May 2005 09:46:50 -0400

> However, something like connector should only get one ID and it can do
> its own multiplexing based on "units".

Yes.  There is no reason connector needs more than one
netlink ID.
