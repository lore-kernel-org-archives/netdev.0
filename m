From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: Please pull from 'from_linus' branch
Date: Sun, 1 Jul 2007 18:31:22 -0500
Message-ID: <FDA9EDFE-8C67-4CFB-91EA-49D07991085F@kernel.crashing.org>
References: <Pine.LNX.4.64.0706290012430.15686@blarg.am.freescale.net> <4684E7C6.6040300@garzik.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, acme@redhat.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:56017 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbXGAXbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2007 19:31:23 -0400
In-Reply-To: <4684E7C6.6040300@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 29, 2007, at 6:06 AM, Jeff Garzik wrote:

> Kumar Gala wrote:
>> Please pull from 'for_linus' branch of
>> 	master.kernel.org:/pub/scm/linux/kernel/git/galak/powerpc.git  
>> for_linus
>> to receive the following updates:
>>  drivers/net/gianfar.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> Kumar Gala (1):
>>       gianfar: Fix typo bug introduced by move to udp_hdr()
>
> Why is net driver stuff no longer going through me?
>
> Fixes are regularly going upstream.

Jeff,

Can you either pull this in your upstream-fixes branch for Linus  
before 2.6.22 comes out.

- k
