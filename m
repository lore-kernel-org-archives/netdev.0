From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 0/5] ipv6:  make af_inet6 subsystems to return an error
 at init
Date: Mon, 10 Dec 2007 16:32:50 +0100
Message-ID: <475D5C22.1090103@fr.ibm.com>
References: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org, pekkas@netcore.fi,
	netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:10624 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbXLJPgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 10:36:55 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id lBAFarkK354544
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:36:53 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBAFarKj4387006
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:36:53 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBAFagFI031233
	for <netdev@vger.kernel.org>; Mon, 10 Dec 2007 15:36:43 GMT
In-Reply-To: <20071210150910.440970057@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano wrote:
> This patchset continue the work to make the different af_inet6 
> subsystems initialization functions to return an error code and
> to handle the error to fails safely.
> 
> It takes into account:
> 	* flowlabel
> 	* exthdrs
> 	* frag
> 	* udp
> 	* udplite
> 	* tcp
> 	* raw

I just noticed that I forgot to put ipv6 under bracket.
Sorry for that :(

Should I resend the patchset ?
