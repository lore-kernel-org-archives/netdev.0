From: "David S. Miller" <davem@redhat.com>
Subject: Re: FIN_WAIT1 / TCP_CORK / 2.2 -- reproducible bug and test case
Date: Thu, 03 Oct 2002 00:56:56 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021003.005656.102625653.davem@redhat.com>
References: <1033388585.16337.9.camel@irongate.swansea.linux.org.uk>
	<Mutt.LNX.4.44.0210031329450.13240-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, mbp@samba.org, kuznet@ms2.inr.ac.ru, ak@muc.de,
   netdev@oss.sgi.com, Alan.Cox@linux.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0210031329450.13240-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Thu, 3 Oct 2002 13:30:44 +1000 (EST)

   On 30 Sep 2002, Alan Cox wrote:
   
   > Well if Dave can't test it and isnt doing any 2.2 who wants to be the
   > 2.2 networking maintainer ?
   
   I'd be willing to give it a go.

So be it.
