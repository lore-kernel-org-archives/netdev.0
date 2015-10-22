From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 3/3] net: ethernet: add driver for Aurora VLSI NB8800 Ethernet controller
Date: Thu, 22 Oct 2015 18:18:31 +0100
Message-ID: <yw1xmvvag6u0.fsf@unicorn.mansr.com>
References: <1445522558-5808-1-git-send-email-mans@mansr.com>
	<1445522558-5808-3-git-send-email-mans@mansr.com>
	<20151022.074116.2063486490315211774.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:42141 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756880AbbJVRSe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:18:34 -0400
In-Reply-To: <20151022.074116.2063486490315211774.davem@davemloft.net> (David
	Miller's message of "Thu, 22 Oct 2015 07:41:16 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Mans Rullgard <mans@mansr.com>
> Date: Thu, 22 Oct 2015 15:02:38 +0100
>
>> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
>> It is an almost complete rewrite of a driver originally found in
>> a Sigma Designs 2.6.22 tree.
>>=20
>> Signed-off-by: Mans Rullgard <mans@mansr.com>
>
> The netdev list is going to have to see patches #1 and #2 as well as
> your cover letter in order to review and integrate this driver
> properly.

Patch 1 only added the "aurora" DT vendor prefix.  Patch 2 was the DT
binding for this device.  I'll include netdev when I send an updated
version.

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
