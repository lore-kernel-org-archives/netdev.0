From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH v2 0/4] XSA-39 CVE-2013-021[67]: Linux netback DoS via
 malicious guest ring.
Date: Fri, 8 Feb 2013 07:54:08 +0000
Message-ID: <1360310048.9063.47.camel@dagon.hellion.org.uk>
References: <1360230078.32479.41.camel@zakaz.uk.xensource.com>
	 <20130207.233107.1094455509765442729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:59488 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab3BHHyK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 02:54:10 -0500
In-Reply-To: <20130207.233107.1094455509765442729.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 04:31 +0000, David Miller wrote:

> Applied, please don't add stable CC:'s to networking patches, instead
> ask me to queue it up to my -stable todo pile instead.

Thanks & Ack.

> I don't like it when patches instantly be submitted to -stable when
> they hit Linus's tree, I'd rather it soak upstream for a week or two
> instead.  That's why I do it this way.

Very reasonable.

Ian.
