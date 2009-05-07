From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] iproute2/tc caching proposal
Date: Thu, 07 May 2009 21:27:02 +0200
Message-ID: <4A033606.3030400@gmail.com>
References: <200905070103.37956.denys@visp.net.lb> <4A032C24.7060709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:48503 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbZEGT1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 15:27:21 -0400
Received: by bwz22 with SMTP id 22so972679bwz.37
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 12:27:21 -0700 (PDT)
In-Reply-To: <4A032C24.7060709@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 05/07/2009 08:44 PM:

> Do you mean 30 sec. is to short for a change? I don't know these things enough;
> your idea looks very nice, but I wonder if you tested how it behaves if e.g.
> after 15k rules some dev goes away which is used in the next 15k?
 
Hmm... actually, it seems there should be no problem, except less info on the

reason of the failure.

 
Jarek P.
