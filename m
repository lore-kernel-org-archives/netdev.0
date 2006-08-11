From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Fri, 11 Aug 2006 10:50:44 +0200
Message-ID: <200608111050.44191.Christophe.Devriese@eurid.eu>
References: <20060802.135859.91441473.davem@davemloft.net> <Pine.LNX.4.64.0608102013020.9012@bizon.gios.gov.pl> <20060810.234538.00788063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from uu212-190-206-99.unknown.uunet.be ([212.190.206.99]:38121 "EHLO
	smtp.eurid.eu") by vger.kernel.org with ESMTP id S1750891AbWHKIuw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 04:50:52 -0400
Received: from localhost (smtp.eurid.eu [127.0.0.1])
	by smtp.eurid.eu (Postfix) with ESMTP id 4CD441252A8
	for <netdev@vger.kernel.org>; Fri, 11 Aug 2006 10:50:49 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060810.234538.00788063.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 August 2006 08:45, David Miller wrote:
> From: Krzysztof Oledzki <olel@ans.pl>
> Date: Thu, 10 Aug 2006 20:18:23 +0200 (CEST)
>
> > OK, this patch really solves the bug from my report. Are there any
> > chances for similar fix in the net-2.6.19.git?
>
> I'm still thinking about this patch and what various people have
> explained about the situation.

What can I do to get you to apply this then ? This patch is about fixing a bug 
which is bothering me a lot.

Regards,

Christophe Devriese
