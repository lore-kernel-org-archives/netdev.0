From: Alan Burlison <Alan.Burlison@oracle.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 12:18:56 +0100
Message-ID: <5628C620.7080503@oracle.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk> <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk> <20151021.182955.1434243485706993231.davem@davemloft.net> <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk> <201510220651.t9M6pKs1018174@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com, Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23855 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbbJVLTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 07:19:10 -0400
In-Reply-To: <201510220651.t9M6pKs1018174@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/10/2015 07:51, Casper.Dik@oracle.com wrote:

> It would more fruitful to have such a discussion in one of the OpenGroup
> mailing lists; people gathered there have a lot of experience and it is
> also possible to fix the standard when it turns out that it indeed as
> vague as you claim it is (I don't quite agree with that)

+1. If there's interest in doing that I'll ask our POSIX rep the best 
way of initiating such a conversation.

-- 
Alan Burlison
--
