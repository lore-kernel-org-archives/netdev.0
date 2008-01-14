From: "Denis V. Lunev" <den@sw.ru>
Subject: Re: [PATCH 1/2 net-2.6.25] [IPV4] Remove extra argument from arp_ignore.
Date: Mon, 14 Jan 2008 17:43:25 +0300
Message-ID: <478B750D.6060407@sw.ru>
References: <1200319481-18459-1-git-send-email-den@openvz.org> <20080114.063753.42458530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:60979 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753161AbYANOn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 09:43:26 -0500
In-Reply-To: <20080114.063753.42458530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> This patch series is numbered, but your other patch series sent a few
> moments ago had no sequence numbers in the subject lines or changelog.
> 
> How can I know what order to apply those in and do they need to go in
> before or after this set?
> 
> I shouldn't have to ask questions like this, so please help avoid
> confusion of this nature in the future.
> 
> Thanks.
> 

non-numbered patches do not intersect with each other.

numbered ones depends on each other but not from the rest.

Sorry for inconvenience :(
