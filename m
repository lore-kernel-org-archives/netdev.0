From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 00/05] ipv6: RFC4214 Support
Date: Wed, 7 Nov 2007 09:23:03 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBED@XCH-NW-7V2.nw.nos.boeing.com>
References: <Pine.LNX.4.64.0711070856130.27362@netcore.fi> <OFF45233E5.73C392C8-ON8825738C.00298603-8825738C.002B4AB8@us.ibm.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE7@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<netdev-owner@vger.kernel.org>, <yoshfuji@linux-ipv6.org>
To: "David Stevens" <dlstevens@us.ibm.com>,
	"Pekka Savola" <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:54732 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbXKGR27 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 12:28:59 -0500
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE7@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As further clarification, here is the US patent office
transaction history for the SRI application, which shows
that the application was rejected on 8/02/04:

http://portal.uspto.gov/external/portal/!ut/p/kcxml/04_Sj9SPykssy0xPLMnM
z0vM0Y_QjzKLN4gPMATJgFieAfqRqCLGpugijnABX4_83FT9IKBEpDlQxNDCRz8qJzU9MblS
P1jfWz9AvyA3NDSi3NsRAHxEBJg!/delta/base64xml/L0lJSk03dWlDU1lKSi9vQXd3QUF
NWWdBQ0VJUWhDRUVJaEZLQSEvNEZHZ2RZbktKMEZSb1hmckNIZGgvN18wXzE4TC81L3NhLmd
ldEJpYg!!?selectedTab=fileHistorytab&isSubmitted=isSubmitted&dosnum=0972
8253&public_selectedSearchOption=

and here is the 12/01/04 "IPR Status" summary from KAME
stating the basis for including ISATAP in their product: 

http://www.kame.net/newsletter/20041201/

Fred
fred.l.templin@boeing.com 

> -----Original Message-----
> From: Templin, Fred L 
> Sent: Wednesday, November 07, 2007 6:42 AM
> To: David Stevens; Pekka Savola
> Cc: David Miller; netdev@vger.kernel.org; 
> netdev-owner@vger.kernel.org; yoshfuji@linux-ipv6.org
> Subject: RE: [PATCH 00/05] ipv6: RFC4214 Support
> 
> I think I can clear this up. The patent office rejected
> SRI's patent application, therefore there are no valid
> claims that could prevent ISATAP from being included
> in public domain software releases. Indeed, Microsoft,
> cisco, and FreeBSD/KAME are shipping ISATAP and have
> been doing so for a long time, and I believe there are
> also several others.
> 
> Fred
> fred.l.templin@boeing.com
> 
> > -----Original Message-----
> > From: David Stevens [mailto:dlstevens@us.ibm.com] 
> > Sent: Tuesday, November 06, 2007 11:54 PM
> > To: Pekka Savola
> > Cc: David Miller; Templin, Fred L; netdev@vger.kernel.org; 
> > netdev-owner@vger.kernel.org; yoshfuji@linux-ipv6.org
> > Subject: Re: [PATCH 00/05] ipv6: RFC4214 Support
> > 
> > > give it away on this specific instance.  I'm not sure if 
> you should 
> > > attribute to hidden agendas what you can explain by "doing 
> > the right 
> > > thing" (granted, very few companies do this which may make 
> > it suspect, 
> > > but still..).
> > 
> > Pekka,
> >         I'm not assuming hidden agendas here; I simply 
> don't know what
> > they mean by "no license for implementers."  It doesn't say they
> > relinquish *all* licensing, which would be clearer if 
> that's what they
> > mean. If implementers, distributors, and users are included, then
> > who's left that does need licensing? If that answer really 
> is nobody,
> > then why bother with "for implementers."?
> >         So, I don't think it's a hidden agenda, I think 
> they said what
> > they mean. I just don't know what they mean. :-)
> > 
> >                                                             
>     +-DLS
> > 
> > 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
