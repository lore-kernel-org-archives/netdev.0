From: Thomas Graf <tgraf@suug.ch>
Subject: Re: IPSEC: on behavior of acquire
Date: Sat, 2 Apr 2005 23:52:56 +0200
Message-ID: <20050402215256.GP3086@postel.suug.ch>
References: <1112405144.1096.33.camel@jzny.localdomain> <20050402140019.GA13017@yakov.inr.ac.ru> <1112478168.1088.337.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        kaber@trash.net, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112478168.1088.337.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1112478168.1088.337.camel@jzny.localdomain> 2005-04-02 16:42
> Herbert also mentions something along the same lines in his email. 
> This would make a lot of sense!
> Is the state machine going to look something along the same lines as
> ARP? i.e incomplete->reachable etc?
> 
> What would be a good code to return when you queue the packet?

EINPROGRESS?
