From: Oleg Verych <olecom@flower.upol.cz>
Subject: Re: [PATCH] warning in SCTP
Date: Thu, 2 Nov 2006 08:30:19 +0000 (UTC)
Message-ID: <slrnekjbho.2in.olecom@flower.upol.cz>
References: <Pine.SOC.4.61.0611020925530.1919@math.ut.ee> <20061102.001643.30183952.davem@davemloft.net> <Pine.SOC.4.61.0611021019540.1919@math.ut.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:12260 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1752532AbWKBIfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 03:35:10 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1GfY2Q-0007h0-5h
	for netdev@vger.kernel.org; Thu, 02 Nov 2006 09:35:04 +0100
Received: from flower.upol.cz ([158.194.64.22])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2006 09:35:02 +0100
Received: from olecom by flower.upol.cz with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2006 09:35:02 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2006-11-02, Meelis Roos wrote:
>> There should only be one space before the "void" in the patch,
>> your email client (or something else) put another space there.
>>
>> Also, your email client likes to turn lines containing only
>> spaces into empty lines, which also corrupts the patch.
>
> cg-diff > file
> and in pine 4.61 ^R read a file. So I guess it's pine misbehaving... 
> Have not heard complaints before but will try to remember to use mutt 
> next time.

(quilt || git) mbox -> formail (procmail package), no MUAs, job's done.
____

