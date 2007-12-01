From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCHv7 iptables] Interface group match
Date: Sat, 01 Dec 2007 22:23:53 +0100
Message-ID: <4751D0E9.8090708@o2.pl>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu> <1196352710402-git-send-email-panther@balabit.hu> <11963527101876-git-send-email-panther@balabit.hu> <11963527103391-git-send-email-panther@balabit.hu> <11963527102332-git-send-email-panther@balabit.hu> <11963527101629-git-send-email-panther@balabit.hu> <4751CFC9.6000607@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Laszlo Attila Toth <panther@balabit.hu>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:33079 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752608AbXLAVWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 16:22:23 -0500
In-Reply-To: <4751CFC9.6000607@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 12/01/2007 10:19 PM:

> Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:
> ...
> 
>> Index: extensions/libxt_ifgroup.man


...

>> +Valid only in the in the

   +Valid only in the

>> +.B FORWARD
>> +and
>> +.B OUTPUT
>> +and
>> +.B POSTROUTING
>> +chains, and user-defined chains which are only called from those
>> +chains. 
>> +.RS
>> +.PP
>> +
> 
> Regards,
> Jarek P.
