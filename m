From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netback: correct return value checks on
 xenbus_scanf()
Date: Thu, 7 Jul 2016 11:35:13 +0100
Message-ID: <20160707103513.GB416@citrix.com>
References: <577E277C02000078000FBEBB@prv-mh.provo.novell.com>
 <577E27B8.2050603@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jan Beulich <JBeulich@suse.com>, Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26502 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751092AbcGGKfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 06:35:15 -0400
Content-Disposition: inline
In-Reply-To: <577E27B8.2050603@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 10:58:16AM +0100, David Vrabel wrote:
> On 07/07/16 08:57, Jan Beulich wrote:
> > Only a positive return value indicates success.
> 
> This is not correct.
> 

Do you mean the commit message is not correct or the code is not
correct? If it is the formal, do you have any suggestion to fix it?

(I was going to just ack this because Paul already reviewed it)

Wei.

> David
