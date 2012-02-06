From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V4 08/13] xenbus_client: extend interface to
 support mapping / unmapping of multi page ring.
Date: Mon, 6 Feb 2012 17:30:57 +0000
Message-ID: <1328549457.17324.20.camel@leeds.uk.xensource.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-9-git-send-email-wei.liu2@citrix.com>
	 <20120203165516.GA20005@phenom.dumpdata.com>
	 <1328289625.7388.38.camel@leeds.uk.xensource.com>
	 <20120206172139.GA26583@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:32798 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab2BFRa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 12:30:29 -0500
In-Reply-To: <20120206172139.GA26583@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-06 at 17:21 +0000, Konrad Rzeszutek Wilk wrote:
> One thing I forgot to mention is that since the backends touch different
> subsystems maintainers tree - you will need to get Acks from all of them
> on a single patch. That should not be an technical issue - except that some
> maintainers can take longer to respond - so your whole patchset might
> be delayed by that.

Sure, that's not a big problem.


Wei.
