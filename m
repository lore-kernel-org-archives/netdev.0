From: "Peter Bieringer" <pb@bieringer.de>
Subject: Re: Debug kernel network hook chain or why has Check Point Firewall module problems with IPv6
Date: Mon, 22 Apr 2002 13:05:46 GMT
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020422130546.17247.qmail@titan.bieringer.de>
References: <22830000.1019458033@localhost>
            <20020422092252.A17861@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Peter Bieringer <pb@bieringer.de>, Maillist netdev <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
In-Reply-To: <20020422092252.A17861@wotan.suse.de>
To: Andi Kleen <ak@suse.de>
List-Id: netdev.vger.kernel.org


Andi Kleen writes:

> BTW the CheckPoint module seems to leak routes too at least on 2.2, 
> there are regular reports of that.

Can you explain what's happen? Perhaps caused by their implementation of
NAT.

 Peter
