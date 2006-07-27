From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel policy vs routing table
Date: Thu, 27 Jul 2006 17:25:05 +0200
Message-ID: <BAY103-F465E15C95576093DD78A3B2580@phx.gbl>
References: <1154011988.16424.13.camel@tahini.andynet.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s34.bay0.hotmail.com ([65.54.246.234]:14677 "EHLO
	bay0-omc3-s34.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S932554AbWG0PZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 11:25:11 -0400
In-Reply-To: <1154011988.16424.13.camel@tahini.andynet.net>
To: andy@andynet.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gay wrote:

>As Herbert said, the right= address doesn't matter. Search for 10.180.

If it doesn't matter, who told to linux to send packets for
10.180.0.0/16 to 172.16.1.253?

>BTW - in your erlier mail you had "rightsubnet=10.180.0./16". Looks like
>a typo there.

yes it was a typo.


