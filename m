From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Sun, 11 May 2008 07:44:22 +0200
Message-ID: <482687B6.5070101@krogh.cc>
References: <20080507.141521.193714938.davem@davemloft.net>	<482498D5.9060008@krogh.cc>	<48258074.7060306@krogh.cc> <20080510.213431.193696750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:35611 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbYEKFo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 May 2008 01:44:29 -0400
In-Reply-To: <20080510.213431.193696750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jesper Krogh <jesper@krogh.cc>
> Date: Sat, 10 May 2008 13:01:08 +0200
> 
>> Any good suggestions about the "Transmit timed out" messages. It
>> currently leads to a system that "doesnt die" but doesnt respond within
>> 15 minutes of load of the network adapter.
> 
> It's likely some bug in the driver that hangs the card for whatever
> reason, which we'll need to work out.

What can I do to help out? I'd really like to get the 10g interface
operational quite soon.

Jesper
-- 
Jesper
