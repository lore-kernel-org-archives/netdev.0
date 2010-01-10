From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] via-velocity: add netpoll functionality for the benefit
 of netconsole
Date: Sun, 10 Jan 2010 10:06:06 +0100
Message-ID: <4B49987E.1020403@computer.org>
References: <4B423440.6060807@computer.org>	<20100105072800.13dba6d2@marrow.netinsight.se>	<4B439ED5.0@computer.org> <20100107072616.4fe2bfb7@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?St=E9phane_Berthelot?= <sberthelot@emisfr.com>
To: Simon Kagstrom <simon.kagstrom@netinsight.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:16556 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752454Ab0AJJKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 04:10:11 -0500
In-Reply-To: <20100107072616.4fe2bfb7@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Kagstrom wrote:
>> I will have to study this, based on other drivers and your commit dfff71.
> 
> Well, if you have tested it and netconsole works with the new driver I
> would guess it's OK. I don't know netconsole myself, but I know the
> interrupt handler (which you call from your patch) has changed with the
> NAPI support, so that's why I was wondering if it still worked.

I want to double-check but can't get my hands on the test machine at the moment. I will revert as soon as.

Thanks, Jan
