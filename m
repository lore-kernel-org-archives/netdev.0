From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: RE: [PATCH 04/05] ipv6: RFC4214 Support
Date: Thu, 8 Nov 2007 13:01:34 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC09@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBF3@XCH-NW-7V2.nw.nos.boeing.com><20071107104524.2bd738cb@freepuppy.rosehill><39C363776A4E8C4A94691D2BD9D1C9A1029EDBF5@XCH-NW-7V2.nw.nos.boeing.com> <20071108.232640.62039057.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: <shemminger@linux-foundation.org>, <netdev@vger.kernel.org>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-smtpout-01.boeing.com ([130.76.64.48]:61499 "EHLO
	slb-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656AbXKHVC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 16:02:29 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071108.232640.62039057.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hmm, what is missing from API POV?

This would have to be determined under a follow-on project (hopefully
with input from others) after we have gained operational experience.

> Since even if you do not change iproute2 now, users may need
> to change their configuration script twice anyway, we should
> be careful.

The unmodified iproute2 gives a basic API that is sufficient for now.
A more feature-rich API can be developed later, but the basic API
will remain in place such that no existing scripts would have to
change and new scripts could benefit from the new API. 

Thanks - Fred
fred.l.templin@boeing.com
 
> --yoshfuji
> 
