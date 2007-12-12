From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Wed, 12 Dec 2007 19:52:00 +0100
Message-ID: <47602DD0.8070402@cosmosbay.com>
References: <475D7901.1040900@nortel.com> <475D7D70.5030502@nortel.com> <47600A6E.8000202@nortel.com> <47601059.8020203@cosmosbay.com> <4760279E.1080203@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp25.orange.fr ([193.252.22.22]:10710 "EHLO smtp25.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbXLLSwE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 13:52:04 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2516.orange.fr (SMTP Server) with ESMTP id A0A7B1C0034A
	for <netdev@vger.kernel.org>; Wed, 12 Dec 2007 19:52:02 +0100 (CET)
In-Reply-To: <4760279E.1080203@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen a =E9crit :
> Eric Dumazet wrote:
>> Chris Friesen a =E9crit :
>>> Is this expected behaviour?
>>
>> Probably not... Still a 2.6.14 kernel ?
>
> Yep.  Embedded hardware, so I'm unable to test with a more recent ker=
nel.
>

And what is the version of "ip" command you have on this machine ?

ip -V

You may try other versions of this command

http://devresources.linux-foundation.org/dev/iproute2/download/





