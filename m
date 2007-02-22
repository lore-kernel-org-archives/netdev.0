From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Slow connection with RTL8168b/8111b
Date: Thu, 22 Feb 2007 09:06:33 +0100
Message-ID: <20070222080633.GA6612@electric-eye.fr.zoreil.com>
References: <88ab4080702210744s1ccf0c8cr504c4f007cc11062@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: Dirk <biecie547@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41956 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbXBVIMN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 03:12:13 -0500
Content-Disposition: inline
In-Reply-To: <88ab4080702210744s1ccf0c8cr504c4f007cc11062@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Edward added to Cc:

Dirk <biecie547@gmail.com> :
[...]

Can you try the patch below against 2.6.21-rc1:

http://www.fr.zoreil.com/people/francois/misc/20070221-2.6.21-rc1-r8169-test.patch

A serie of incremental patches for the same changes is available at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc1/r8169

I am still working on the patches: do not be surprized if there are big
regressions.

-- 
Ueimor
