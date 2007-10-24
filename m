From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 13/13] r8169: more phy init for the 8168
Date: Thu, 25 Oct 2007 00:14:38 +0200
Message-ID: <20071024221438.GB6189@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com> <20071018210224.GN31724@electric-eye.fr.zoreil.com> <471F1067.50403@lincor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: Glen Gray <glen.gray@lincor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43682 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755317AbXJXWUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 18:20:52 -0400
Content-Disposition: inline
In-Reply-To: <471F1067.50403@lincor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Glen Gray <glen.gray@lincor.com> :
> Are any of these likely to fix the Ethernet multicast issues a few of us 
> have seen with 8110sc cards ?

No, this serie is not expected to.

I have planned to work on it again during the bugfix phase of 2.6.24-rc.

Is it still an option for you to use the old realtek driver + bandaid
(no pun) in the meantime ?

-- 
Ueimor
