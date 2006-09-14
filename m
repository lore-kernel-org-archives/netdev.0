From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to sockets	that are joined to group
Date: Thu, 14 Sep 2006 14:30:37 +0400
Message-ID: <20060914103037.GB19959@ms2.inr.ac.ru>
References: <20060913202029.GA4666@ms2.inr.ac.ru> <OFD3BF4B0D.1F917BE2-ON882571E8.00716451-882571E8.0071B6B7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:3981 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751054AbWINKbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 06:31:12 -0400
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFD3BF4B0D.1F917BE2-ON882571E8.00716451-882571E8.0071B6B7@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

>         No, it returns 1 (allow) if there are no filters to explicitly
> filter it. I wrote that code. :-)

I see. It did not behave this way old times.

>From your mails I understood that current behaviour matches another
implementations (BSD whatever), is it true?

Alexey
