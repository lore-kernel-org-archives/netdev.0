From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: make unexported functions static
Date: Thu, 9 Jun 2016 14:00:54 +0100
Message-ID: <fbf1d568-8be2-b8e2-2244-de5f6a13f623@codethink.co.uk>
References: <1465468206-2890-1-git-send-email-ben.dooks@codethink.co.uk>
 <87fusm8rbd.fsf@ketchup.mtl.sfl> <87fusm8r6a.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:48576 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbcFINBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 09:01:01 -0400
In-Reply-To: <87fusm8r6a.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/16 13:47, Vivien Didelot wrote:
> Hi Ben,
> 
> Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:
> 
>> Most of them are fixed or being handled in net-next.
>>
>> I don't know if net should diverge or if it can live with these
>> warnings...
> 
> In fact I have a series in net-next fixing a few checkpatch.pl issue. If
> you don't mind I can rebase your fix and integrate the missing static.

Ah, didn't check net-next. You are welcome to rebase.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
