From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: slow samba performance
Date: Mon, 3 Sep 2007 23:03:22 +0200
Message-ID: <20070903210322.GB4444@electric-eye.fr.zoreil.com>
References: <46CC66D3.8030602@gmail.com> <20070822182116.GA5445@csy.ca> <46CC9290.3040501@gmail.com> <Pine.SOC.4.64.0708271631330.871@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bruce Cole <bacole@gmail.com>, netdev@vger.kernel.org
To: john@BlueSkyTours.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51458 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428AbXICVFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2007 17:05:09 -0400
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.64.0708271631330.871@katana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

john@BlueSkyTours.com <john@BlueSkyTours.com> :
[...]
> I have had abysmal performance trying to remotely run X apps via ssh on a
> computer with a RTL8111 NIC.  Saw this message and decided to give this
> patch a try --- success!  Much, much better.

Can you give a try to:

http://www.fr.zoreil.com/people/francois/misc/20070903-2.6.23-rc5-r8169-test.patch

or just patches #0001 + #0002 at:

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.23-rc5/r8169-20070903/


-- 
Ueimor
