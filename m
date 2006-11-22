From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Wed, 22 Nov 2006 13:00:54 +0100
Message-ID: <45643BF6.1000305@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>	 <20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org>	 <4541CCF4.4050306@fr.ibm.com> <1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:13715 "EHLO
	mtagate5.de.ibm.com") by vger.kernel.org with ESMTP
	id S1162055AbWKVLA5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 06:00:57 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id kAMB0tw5164266
	for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 11:00:55 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAMB4NGs2920518
	for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 12:04:23 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAMB0sqP007434
	for <netdev@vger.kernel.org>; Wed, 22 Nov 2006 12:00:55 +0100
To: hadi@cyberus.ca, Stephen Hemminger <shemminger@osdl.org>,
	netdev@vger.kernel.org
In-Reply-To: <4559DE01.5090109@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano wrote:
>> Then a matrix of how each requires what modifications in the network
>> code. Of course all players need to agree that the description is
>> accurate.
>> Is there such a document?
>>
>> cheers,
>> jamal
> 
> Hi,
> 
> the attached document describes the network isolation at the layer 2 and 
> at the layer 3, it presents the pros and cons of the different 
> approaches, their common points and the impacted network code.
> I hope it will be helpful :)
> 
> Cheers.
> 
>    -- Daniel


Hi,

does the document clarify the layer 2 / layer 3 approaches ? Does it 
bring some elements of response ? Is there missing something in it ?
Do you need more informations ?

Regards

	-- Daniel
