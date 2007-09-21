From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e1000 driver and samba
Date: Sat, 22 Sep 2007 00:41:13 +0200
Message-ID: <20070921224113.GA2375@electric-eye.fr.zoreil.com>
References: <46F302A8.7040008@gmail.com> <20070921214916.GA2386@electric-eye.fr.zoreil.com> <46F43F4B.7090903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bruce Cole <bacole@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37269 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932555AbXIUWnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 18:43:19 -0400
Content-Disposition: inline
In-Reply-To: <46F43F4B.7090903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bruce Cole <bacole@gmail.com> :
> Francois Romieu wrote:
[...]
> >Can you be more specific ?
> >  
> Yes per the reference I gave:
> http://www.spinics.net/lists/netdev/msg40384.html
[...]

Ok, I wondered if you had found something between the start_xmit and the
Tx completion code.

[...]
> I could probably help fix the underlying problem but I didn't
> receive any response to my post quoted above.

I have submitted the smallest workaround to Jeff. It is not necessarily
the best wrt performance but this part is not trivial to arbitrate.

-- 
Ueimor
