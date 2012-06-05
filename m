From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and whitespace
 cleanups
Date: Tue, 05 Jun 2012 12:49:43 +0200
Message-ID: <4FCDE447.3030103@computer.org>
References: <4FCD084D.6020408@computer.org> <20120604.155229.822064530175335346.davem@davemloft.net> <4FCD9F15.2050605@computer.org> <20120605.051437.1378262604943296071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:54618 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849Ab2FEKt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 06:49:56 -0400
In-Reply-To: <20120605.051437.1378262604943296071.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2012 11:14 AM, David Miller wrote:
> From: Jan Ceuleers <jan.ceuleers@computer.org>
> Date: Tue, 05 Jun 2012 07:54:29 +0200
> 
>> So your build environment happens to be one of powerpc, alpha or mips,
>> does it?
> 
> No, I get those errors you posted too.
> 
> But like I said, you simply IGNORE THEM, and look for newly introduced
> errors and warnings.

David,

The error I quoted was a fatal error, meaning that compilation did not
proceed beyond the point to which the error pertained (inclusion of a
header that does not exist in my arch). So I cannot test-compile the
driver on my arch and draw any conclusions from that beyond line 91.

I really wanted to make a modest contribution with this patch set, and
it seems I've failed miserably due to the amount of other people's
bandwidth that I'm consuming...

Jan
