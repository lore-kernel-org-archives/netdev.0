From: Guillaume Chazarain <guichaz@yahoo.fr>
Subject: Re: Re : Oops preceded by WARNING: at net/ipv4/tcp_input.c:1571
 tcp_remove_reno_sacks()
Date: Thu, 15 Nov 2007 11:31:20 +0100
Message-ID: <20071115113120.7276ad52@cheypa.inria.fr>
References: <902344.71635.qm@web26211.mail.ukl.yahoo.com>
	<Pine.LNX.4.64.0711111216170.12719@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0711132321340.3997@kivilampi-30.cs.helsinki.fi>
	<20071113.210431.141662500.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:3814 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760593AbXKOKlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 05:41:13 -0500
In-Reply-To: <20071113.210431.141662500.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Chazarain please let us know if it does indeed cure your
> problem.

Unfortunately, I couldn't manage to reproduce the problem with an
unpatched kernel. But your investigation Ilpo was really impressive.

BTW, even though I messed up the yahoo webmail configuration, you can
call me by my first name: Guillaume ;-)

Thanks again for such an awesome bug fixing attitude!

-- 
Guillaume
