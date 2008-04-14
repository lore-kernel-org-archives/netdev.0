From: Patrick McHardy <kaber@trash.net>
Subject: Re: HTB and ingress scheduler SMP Soft Lockup in 2.6.23-2.6.25-rc8
Date: Mon, 14 Apr 2008 09:20:02 +0200
Message-ID: <480305A2.7040906@trash.net>
References: <47FFAFFA.7070802@superclick.com> <4801BB96.5010406@trash.net> <48025CE3.7080807@superclick.com> <48030446.1090103@trash.net> <4803047A.2070408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Enrico Demarin <enrico@superclick.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64081 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755926AbYDNHUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 03:20:06 -0400
In-Reply-To: <4803047A.2070408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Patrick McHardy wrote:
>> Enrico Demarin wrote:
>>> Hi Patrick,
>>>
>>> here it is, hope it will work out this time
>>
>> Thanks. Could you try whether this patch fixes it please?
> 
> 
> That one was broken, this one should work.

Actually both don't fix the problem, sorry. Will retry
after another coffee :)
