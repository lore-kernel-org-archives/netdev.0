From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 15:53:41 +0000
Message-ID: <562F9E05.6080009@oracle.com>
References: <562F868B.4040001@oracle.com>	<20151027.073914.310976982324296607.davem@davemloft.net>	<562F8CBC.7080800@oracle.com> <20151027.080434.2260743137698389975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48582 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964838AbbJ0Px7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 11:53:59 -0400
In-Reply-To: <20151027.080434.2260743137698389975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/10/2015 15:04, David Miller wrote:

> I said "run time".  Like when your final code runs on a target system.
>
> Not at build tree configure time.

Yes, you could do it then as well.

-- 
Alan Burlison
--
