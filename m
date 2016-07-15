From: "Steve Wise" <swise@opengridcomputing.com>
Subject: RE: [net-next 6/6] cxgb3i,cxgb4i: fix symbol not declared sparse warning
Date: Fri, 15 Jul 2016 09:17:39 -0500
Message-ID: <09cb01d1dea3$a4acf950$ee06ebf0$@opengridcomputing.com>
References: <cover.1467998292.git.varun@chelsio.com> <bd0f185a6dafaf31d825b67758eaec01e69f7c36.1467998293.git.varun@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
	<target-devel@vger.kernel.org>, <nab@linux-iscsi.org>,
	<gerlitz.or@gmail.com>, <james.bottomley@hansenpartnership.com>,
	<indranil@chelsio.com>
To: "'Varun Prakash'" <varun@chelsio.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:56595 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751940AbcGOORf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 10:17:35 -0400
In-Reply-To: <bd0f185a6dafaf31d825b67758eaec01e69f7c36.1467998293.git.varun@chelsio.com>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Fix following sparse warnings
> warning: symbol 'cxgb3i_ofld_init' was not declared. Should it be static?
> warning: symbol 'cxgb4i_cplhandlers' was not declared. Should it be static?
> warning: symbol 'cxgb4i_ofld_init' was not declared. Should it be static?
> 
> Signed-off-by: Varun Prakash <varun@chelsio.com>

looks fine.

Reviewed-by: Steve Wise <swise@opengridcomputing.com>
