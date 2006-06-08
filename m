From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2.6.17-rc6-mm1 ] net: RFC 3828-compliant UDP-Lite support
Date: Thu, 8 Jun 2006 21:09:33 +0100
Message-ID: <200606082109.34338.gerrit@erg.abdn.ac.uk>
References: <200606081150.34018@this-message-has-been-logged> <20060608.115331.71094388.davem@davemloft.net> <Pine.LNX.4.64.0606081542390.3555@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, yoshfuji@linux-ipv6.org,
	kaber@coreworks.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:35774 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S964960AbWFHUKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 16:10:10 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0606081542390.3555@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting James Morris:
|  On Thu, 8 Jun 2006, David Miller wrote:
|  
|  > > Understood. Please, anyone, disregard or un-apply the previous
|  > > UDP-Lite patch.  A revised patch will be prepared and posted as soon
|  > > as testing permits.
|  > 
|  > Nobody is going to integrate your patch anywhere, don't worry.
|  > You make it clear that once you toss this piece of code over
|  > the wall, you'll disappear.
|  
|  Having dealt with more than enough code thrown over the wall in recent 
|  times, I agree.

I understand the points of both of you well enough. But how come this is interpreted 
as saying I'd "toss this piece of code over the wall"? I can understand getting tired 
of cowboy coding jobs, but there is a misunderstanding here.

Of course do and will I maintain that code and every issue related it. I have been
maintaining, improving, testing this code for 9 months. The protocol spec (RFC 3828)
was developed at University of Aberdeen, and there is continuing research into 
UDP-Lite here, i.e. it is not a `dead' project. That is why I held back regarding the 
IPv6 port: I can ensure that this (IPv4) code is up to standard and to date, but am 
lacking the required additional time to implement the same for IPv6. 
I am trying to contact people to help with the port, but for the moment I will take 
responsibility only for the IPv4 version.

And if there is someone `well-known and respected' who is interested in taking this code 
over, I would only be happy for him/her to do this. But I won't simply `disappear' :-)






