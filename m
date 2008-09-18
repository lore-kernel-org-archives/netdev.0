From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Subject: Re: clarify code intent
Date: Thu, 18 Sep 2008 16:53:40 -0700
Message-ID: <1221782020.23007.37.camel@ns-test>
References: <1221757668.23007.12.camel@ns-test>
	 <20080918.163633.223533656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:51953 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754452AbYIRXxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:53:00 -0400
In-Reply-To: <20080918.163633.223533656.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-09-18 at 16:36 -0700, David Miller wrote:

> This is just syntactic masterbation, sa_family_t is typedef'd
> "unsigned short".

Would you take a patch to remove sa_family_t from the kernel code and
headers ? Otherwise, I suspect that you can understand that it is a bit
hard for others to figure out where it is appropriate to use it and
where it is not.

regards,
Mathieu

