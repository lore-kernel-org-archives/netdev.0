From: Patrick McHardy <kaber@trash.net>
Subject: Re: netlink circular locking dependency
Date: Wed, 18 Jun 2008 13:42:27 +0200
Message-ID: <4858F4A3.8060500@trash.net>
References: <20080617134303.GC4632@ff.dom.local>	 <20080617.213012.132043917.davem@davemloft.net>	 <4858CCCE.7060404@trash.net>	 <20080618.020831.214323427.davem@davemloft.net> <1213789103.19872.0.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, mingo@elte.hu, tgraf@suug.ch
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61672 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbYFRLmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 07:42:31 -0400
In-Reply-To: <1213789103.19872.0.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann wrote:
> Hi David,
> 
>>>> In the meantime should I apply Patrick's current patch
>>>> from this thread?
>>> I think that makes sense, the module unload race is present anyway.
>>>> If so I'd like a proper commit message and signoff, thanks!
>>> Attached the patch with a proper changelog.
>> Applied and pushed out to net-2.6, thanks a lot Patrick.
> 
> you could have added a Tested-by: Marcel Holtmann <marcel@holtmann.org>

My fault, I wanted to but forgot due to lack of coffee :)
