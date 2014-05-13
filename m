From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: [PATCH net-next 01/11] net: cdc_ncm: split out rx_max/tx_max
 update of setup
Date: Tue, 13 May 2014 11:40:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.03.1405131138210.1290@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; format=flowed
Cc: Alexey Orishko <alexey.orishko@gmail.com>,
	David Laight <David.Laight@aculab.com>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:37363 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932681AbaEMJki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 05:40:38 -0400
Content-ID: <alpine.LNX.2.03.1405131138212.1290@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: I am re-sending the mail, since I sent it privately to Bj*rn only, by 
mistake. Sorry. And sorry also for continously mistyping your name: I would 
like to learn writing it right! :)

I would also propose some polite warning message regarding what's happening.
Ok, I know it may simply be SPAM for users, but it may help identifying devices
not behaving properly in regard to specifications.
I know - it doesn't make much sense, even considering there are simply devices
that will act like NCM but use AT for signaling reasons. But with this message,
the kernle may inform users about a situation like:
2oh - I am trying to do my best. If performances are not as good as they might
be, proceed with ..."
This is only a proposal, nothing more.

Enrico
