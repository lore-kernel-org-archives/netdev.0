From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 3/8] xen-netback: support multiple extra info
 segments passed from frontend
Date: Mon, 26 Oct 2015 17:05:28 +0000
Message-ID: <20151026170528.GD18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-4-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14380 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbJZRGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:06:24 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-4-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:20AM +0100, Paul Durrant wrote:
> The code does not currently allow a frontend to pass multiple extra info
> segments to the backend in a tx request. A subsequent patch in this series
> needs this functionality so it is added here, without any other
> modification, for better bisectability.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
