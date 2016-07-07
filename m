From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: correct return value checks on
 xenbus_scanf()
Date: Thu, 7 Jul 2016 10:56:21 +0100
Message-ID: <577E2745.3060400@citrix.com>
References: <577E280402000078000FBEC7@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>, <david.vrabel@citrix.com>,
	<boris.ostrovsky@oracle.com>, Juergen Gross <JGross@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64591 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418AbcGGJ5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 05:57:03 -0400
In-Reply-To: <577E280402000078000FBEC7@prv-mh.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07/16 08:59, Jan Beulich wrote:
> Only a positive return value indicates success.

This checks were already correct.

David
