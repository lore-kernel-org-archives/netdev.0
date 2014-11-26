From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Wed, 26 Nov 2014 21:53:27 +0000
Message-ID: <20141126215327.GC13786@casper.infradead.org>
References: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com>
 <20141126105614.6a42d697@urahara>
 <54763AA6.4000804@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	vyasevich@gmail.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, sashok@cumulusnetworks.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:34925 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbaKZVx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 16:53:28 -0500
Content-Disposition: inline
In-Reply-To: <54763AA6.4000804@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/14 at 12:40pm, Roopa Prabhu wrote:
> I have always wondered, if binary netlink attributes have this restriction,
> they should be discouraged. especially when the other extensible option is
> to add them as a separate netlink attribute.

This is pretty much exactly the reason why attributes have been
introduced ;-)
