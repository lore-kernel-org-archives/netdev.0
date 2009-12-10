From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/2] net: use compat helper functions in
 compat_sys_recvmmsg
Date: Thu, 10 Dec 2009 10:46:40 -0200
Message-ID: <20091210124640.GA20963@ghostprotocols.net>
References: <20091210065914.GB4144@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbZLJMqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 07:46:40 -0500
Content-Disposition: inline
In-Reply-To: <20091210065914.GB4144@osiris.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Dec 10, 2009 at 07:59:15AM +0100, Heiko Carstens escreveu:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> 
> Use (get|put)_compat_timespec helper functions to simplify the code.
> 
> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
> Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Nice cleanup, thanks!

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
