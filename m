From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv4: arp: update neighbour address when a
 gratuitous arp is received and arp_accept is set
Date: Thu, 02 Jan 2014 00:09:03 -0500 (EST)
Message-ID: <20140102.000903.1082083240842999143.davem@davemloft.net>
References: <1387923422-4247-1-git-send-email-noureddine@aristanetworks.com>
	<20140101.233834.1721631702711130638.davem@davemloft.net>
	<CAO7SqHAKtoTr2VeE48dncfSB50cB9LEzp65abjeJuCSe0s6KLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hannes@stressinduktion.org, netdev@vger.kernel.org
To: noureddine@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787AbaABFJE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:09:04 -0500
In-Reply-To: <CAO7SqHAKtoTr2VeE48dncfSB50cB9LEzp65abjeJuCSe0s6KLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Salam Noureddine <noureddine@aristanetworks.com>
Date: Wed, 1 Jan 2014 21:06:10 -0800

> This patch is against net-next, sorry forgot to mention it in the
> subject. Hannes pointed changes made to arp.c in net-next so I
> generated this patch accordingly.

Thanks for the clarification, applied.
