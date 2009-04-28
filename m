From: David Miller <davem@davemloft.net>
Subject: Re: inet_diag: Remove dup assignments
Date: Tue, 28 Apr 2009 08:03:34 -0700 (PDT)
Message-ID: <20090428.080334.153766935.davem@davemloft.net>
References: <20090428135636.GF19908@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56529
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755544AbZD1PDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 11:03:41 -0400
In-Reply-To: <20090428135636.GF19908@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 28 Apr 2009 10:56:36 -0300

> These are later assigned to other values without being used meanwhile.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied, thanks.
