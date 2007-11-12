From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [Resend][PATCH 01/05] ipv6: RFC4214 Support (4)
Date: Mon, 12 Nov 2007 14:26:12 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC23@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <4738CF78.6030804@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC21@XCH-NW-7V2.nw.nos.boeing.com> <4738D238.8050105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <yoshfuji@linux-ipv6.org>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:58174 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbXKLW0u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 17:26:50 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4738D238.8050105@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Ok, thanks for the explanation.  One questions is though why
> do we need all the #if defines() throughout the file?

Was just trying to follow what I thought was
convention, but I'm willing to be educated...

> Most distros end up enabled almost everything anyway.  Looking
> at the code, there is really nothing that needs a conditional.
> Removing the conditionals would make things cleaner.

Works for me unless there are any objections. Anyone?

Fred
fred.l.templin@boeing.com
 
> Just some of my thoughts.
> 
> Thanks
> -vlad
