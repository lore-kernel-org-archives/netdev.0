From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] flow_dissector: Use 'const' where possible.
Date: Tue, 01 Sep 2015 21:47:26 -0700
Message-ID: <1441169246.12163.29.camel@perches.com>
References: <20150901.211944.1246891781745159331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0156.hostedemail.com ([216.40.44.156]:36062 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750783AbbIBEr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 00:47:29 -0400
In-Reply-To: <20150901.211944.1246891781745159331.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-01 at 21:19 -0700, David Miller wrote:
> Signed-off-by: David S. Miller <davem@davemloft.net>
[]
>  net/core/flow_dissector.c | 79 ++++++++++++++++++++++++-----------------------

Thanks David.
