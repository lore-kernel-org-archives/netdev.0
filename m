From: "Brian F. G. Bidulock" <bidulock@openss7.org>
Subject: Re: linux 2.6.16 routing problem
Date: Fri, 14 Jul 2006 06:31:23 -0600
Message-ID: <20060714063123.A21577@openss7.org>
References: <d096a3ee0607140525r3e1fb9dbg399c87bb3fbe4205@mail.gmail.com>
Reply-To: bidulock@openss7.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.openss7.com ([142.179.199.224]:29125 "EHLO gw.openss7.com")
	by vger.kernel.org with ESMTP id S1161097AbWGNMbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 08:31:24 -0400
To: Mayuresh Chitale <mchitale@gmail.com>
Content-Disposition: inline
In-Reply-To: <d096a3ee0607140525r3e1fb9dbg399c87bb3fbe4205@mail.gmail.com>; from mchitale@gmail.com on Fri, Jul 14, 2006 at 05:55:10PM +0530
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mayuresh,

On Fri, 14 Jul 2006, Mayuresh Chitale wrote:
> 
> If anyone has solved similar problem or knows what causes this
> problem, please let me know.
> 
> Any suggestion is welcome.

Configure a static arp entry for the tester on the unit under test.
(Or configure the tester to respond to ARP queries.)

--brian

