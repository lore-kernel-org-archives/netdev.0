From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH 11/13] xen-netfront: feature-persistent
 xenbus support
Date: Mon, 18 May 2015 16:51:49 +0100
Message-ID: <555A0A95.20409@citrix.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-12-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:59100 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391AbbERPvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:51:53 -0400
In-Reply-To: <1431451117-70051-12-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/05/15 18:18, Joao Martins wrote:
> "feature-persistent" check on xenbus for persistent grants
> support on the backend.

You can't expose/check for this feature until you actually support it.
This should probably be the last patch.

David
