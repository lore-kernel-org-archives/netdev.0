From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: crash on remove
Date: Tue, 23 Oct 2007 20:23:23 -0400
Message-ID: <471E907B.8060201@pobox.com>
References: <bug-9208-10286@http.bugzilla.kernel.org/> <20071022111235.266a10df.akpm@linux-foundation.org> <20071022133909.6a5453c7@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	jkarlson@cc.hut.fi
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35994 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbXJXAXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 20:23:25 -0400
In-Reply-To: <20071022133909.6a5453c7@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix off-by one in remove logic that just got introduced.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
> This only occurs in new post 2.6.23 code.

applied


