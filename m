From: "Hollenbeck, Scott" <shollenbeck@verisign.com>
Subject: RE: tunneling in linux (was: Re: [PATCH][RFC] etherip: Ethernet-i
	n-IPv4 tunneling)
Date: Tue, 18 Jan 2005 07:54:01 -0500
Message-ID: <046F43A8D79C794FA4733814869CDF07057840@dul1wnexmb01.vcorp.ad.vrsn.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "'Pekka Savola'"
	 <pekkas@netcore.fi>,
        "'shemminger@osdl.org'" <shemminger@osdl.org>,
        "'Russ Housley'" <housley@vigilsec.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Lennert Buytenhek'" <buytenh@wantstofly.org>,
        "'jamal'"
	 <hadi@cyberus.ca>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > BTW, in one of your emails i
> > noticed you cced the authors of that RFC - did they 
> respond? Whats their
> > deployment experiences?
> 
> The @rsa.. address bounces, the other address is still in the CC list
> and I didn't hear from him yet :-)

The correct current address for Russ is housley@vigilsec.com.  I've cc'd him
here.

So what do you want to hear?  As the RFC says, etherIP documents work that
Russ and I did at Xerox during the early 1990s.  It was developed and
deployed for use in conjunction with the Xerox Encryption Unit (XEU), a
layer 2 (Ethernet/802.3) network encryption device.  As the XEU was never a
big seller etherIP never really got "out there", either, but it certainly
worked in the environment for which it was intended.

-Scott-
