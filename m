From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v3 05/10] bql: Byte queue limits
Date: Tue, 29 Nov 2011 16:59:25 -0800
Message-ID: <20111129165925.48039b3a@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1111222140410.15246@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48432 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3A71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 19:59:27 -0500
In-Reply-To: <alpine.DEB.2.00.1111222140410.15246@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is great to see new features, but we keep adding stuff with no
visible user documentation!

Every new feature added to networking should entry in Documentation/networking/
as part of the patchset.
