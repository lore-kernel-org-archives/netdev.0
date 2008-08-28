From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 0/6] Pull request for 'r8169-fixes' branch
Date: Thu, 28 Aug 2008 23:20:01 +0200
Message-ID: <20080828212001.GA28295@electric-eye.fr.zoreil.com>
References: <20080817162330.GA18690@electric-eye.fr.zoreil.com> <48B52191.2020309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60180 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754244AbYH1VVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 17:21:19 -0400
Content-Disposition: inline
In-Reply-To: <48B52191.2020309@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> :
[...]
> The patches look fine, but it wasn't really -rc3 material (released Aug 13, 
> you posted this Aug 17) to add register descriptions and new hardware 
> support.

It was shaken a bit sooner than that. It is not months old though.

> Is any of this critical for 2.6.27?

8102 users may disagree but is imho not worth getting davem burned
again. -next should be fine.

> I already applied the map/unmap fix.

Thanks.

-- 
Ueimor
