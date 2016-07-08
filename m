From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: prefer xenbus_write() over xenbus_printf()
 where possible
Date: Fri, 8 Jul 2016 17:13:49 +0100
Message-ID: <20160708161349.GB24399@citrix.com>
References: <577E27BA02000078000FBEC3@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6776 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755145AbcGHQNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jul 2016 12:13:52 -0400
Content-Disposition: inline
In-Reply-To: <577E27BA02000078000FBEC3@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 01:58:18AM -0600, Jan Beulich wrote:
> ... as being the simpler variant.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
