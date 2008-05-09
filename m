From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 16:21:33 -0700
Message-ID: <4824DC7D.6000305@sun.com>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
 <20080507.141521.193714938.davem@davemloft.net> <482498D5.9060008@krogh.cc>
 <20080509.143229.174354251.davem@davemloft.net> <4824C936.9000103@krogh.cc>
 <4824CBA1.8040703@sun.com> <4824CCF0.5050302@krogh.cc>
 <4824D1E1.10007@sun.com> <4824D39B.6040006@sun.com> <4824D9CD.4050402@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:45027 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbYEIXVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 19:21:34 -0400
In-reply-to: <4824D9CD.4050402@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> Matheos Worku wrote:
>>>> Thats a transmit.. from the NFS server to the clients.
>>>
>> Is MSI/MSI-X enabled on the kernel? I have noticed that it was not 
>> enabled on Gutsy-SPARC?
> 
> # grep MSI .config
> CONFIG_ARCH_SUPPORTS_MSI=y
> CONFIG_PCI_MSI=y
> 
> Should that be ok?
> 
That should be ok.

