From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 17:12:44 +0000
Message-ID: <5632538C.7070401@oracle.com>
References: <201510221951.t9MJp5LC005892@room101.nl.oracle.com> <20151022215741.GW22011@ZenIV.linux.org.uk> <201510230952.t9N9qYZJ021998@room101.nl.oracle.com> <20151024023054.GZ22011@ZenIV.linux.org.uk> <201510270908.t9R9873a001683@room101.nl.oracle.com> <562F577E.6000901@oracle.com> <20151029145847.GA10859@netbsd.org> <563238D0.2040802@oracle.com> <20151029160131.GA18961@netbsd.org> <56324625.9000803@oracle.com> <20151029170748.GG22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32073 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757225AbbJ2RMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 13:12:54 -0400
In-Reply-To: <20151029170748.GG22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[off list]

On 29/10/2015 17:07, Al Viro wrote:

> Could the esteemed sir possibly be ars^H^H^Hprevailed upon to quote the exact
> place in POSIX that requires such behaviour?

If that's the way the conversation is going to go, sorry, no.

-- 
Alan Burlison
--
