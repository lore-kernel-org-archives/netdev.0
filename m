From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Thu, 24 May 2012 20:03:13 +0200
Message-ID: <4FBE77E1.4010103@computer.org>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com>  <20120522.151830.2018953337014839778.davem@davemloft.net>  <4FBE4E02.1070306@computer.org> <1337876210.5070.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, b06378@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:51082 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964839Ab2EXSHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 14:07:51 -0400
In-Reply-To: <1337876210.5070.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2012 06:16 PM, Joe Perches wrote:
> On Thu, 2012-05-24 at 17:04 +0200, Jan Ceuleers wrote:
>> On 05/22/2012 09:18 PM, David Miller wrote:
>>> Someone needs to go through this driver when net-next opens up
>>> and fix all of the indentation in this driver.
>>
>> May I give that a go?
> 
> I have scripts that automate most of this.
> I don't have the card though.
> 
> Maybe this is a starting point?
> It doesn't fix most 80 column warnings.

Thanks Joe.

I also don't have the card; the kinds of changes I was proposing to make
are code-neutral, whose correctness I was intending to prove by a binary
compare of the before-and-after .o.

Still happy to do that taking your contribution as a starting point.

Thanks, Jan
