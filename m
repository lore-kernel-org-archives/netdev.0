From: Jon Loeliger <jdl@freescale.com>
Subject: Re: [PATCH] fs_enet: restore promiscuous and multicast settings in
 restart()
Date: Thu, 19 Jun 2008 13:47:27 -0500
Message-ID: <485AA9BF.6090403@freescale.com>
References: <200806181707.17739.laurentp@cse-semaphore.com>	<8496f91a0806181145w62d57a7fua767c8036f2261aa@mail.gmail.com> <20080619222042.2910e284@vitb.ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: matvejchikov@gmail.com, linuxppc-dev <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org,
	linuxppc-embedded <linuxppc-embedded@ozlabs.org>
To: Vitaly Bordug <vbordug@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45181 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753353AbYFSSrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 14:47:41 -0400
In-Reply-To: <20080619222042.2910e284@vitb.ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vitaly Bordug wrote:
> On Wed, 18 Jun 2008 22:45:57 +0400
> "Matvejchikov Ilya" <matvejchikov@gmail.com> wrote:
> 
>> I'm glad that you have corrected it. Half a year ago I pointed out
>> that there was such a mistake:
>> http://patchwork.ozlabs.org/linuxppc/patch?id=10700
>>
> You've used -embedded ML, and patch wasn't noticed... 

*sigh*

We should merge the -embedded list into -dev
and retire the -embedded list finally.

jdl


