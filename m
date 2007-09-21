From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e1000 driver and samba
Date: Fri, 21 Sep 2007 23:49:16 +0200
Message-ID: <20070921214916.GA2386@electric-eye.fr.zoreil.com>
References: <46F302A8.7040008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Bruce Cole <bacole@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:56469 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755558AbXIUVvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 17:51:18 -0400
Content-Disposition: inline
In-Reply-To: <46F302A8.7040008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bruce Cole <bacole@gmail.com> :
> >If you look for it on the Realtek cards, there had been sporadic
> >Nissues up to late 2005. The solution posted universally was 'change
> >card'.
> 
> Yes, that *was* the common recommendation.

There was no such thing as a universal solution to sporadic issues.

[...]
> I suspect the root problem is the driver isn't properly locking
> the TX queue.

Can you be more specific ?

-- 
Ueimor
