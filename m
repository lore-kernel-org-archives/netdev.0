From: <ben@bigfootnetworks.com>
Subject: RE: Bridge + Conntrack + SKB Recycle: Fragment Reassembly Errors
Date: Tue, 1 Dec 2009 09:00:30 -0700
Message-ID: <767BAF49E93AFB4B815B11325788A8ED4B1FDC@L01SLCXDB03.calltower.com>
References: <767BAF49E93AFB4B815B11325788A8ED45F0BA@L01SLCXDB03.calltower.com>	<4AF999DE.9060206@trash.net> <20091121.110832.213888237.davem@davemloft.net> <4B0883FD.2090806@trash.net> <4B088600.8090209@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from L01SLCSMTP02.calltower.com ([69.4.184.249]:32385 "EHLO
	L01SLCSMTP02.calltower.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753500AbZLAQAs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 11:00:48 -0500
Content-class: urn:content-classes:message
In-Reply-To: <4B088600.8090209@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ben, please give this patch a try.

I have not been able to recreate the issue after applying the patch,
which is great.  Is this the only case in which large-ish SKBs might be
recycled and cause the reassembly overflow?

- Ben Menchaca
