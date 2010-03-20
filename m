From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 15541] New: POLLIN bit is set when there is
 OOB data only
Date: Fri, 19 Mar 2010 19:42:47 -0700 (PDT)
Message-ID: <20100319.194247.193697670.davem@davemloft.net>
References: <bug-15541-10286@http.bugzilla.kernel.org/>
	<20100319155541.731eec28.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexandra.Kossovsky@oktetlabs.ru,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33817
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752466Ab0CTCmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 22:42:25 -0400
In-Reply-To: <20100319155541.731eec28.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The patch is already in Linus's tree Andrew.

Stephen Hemminger forwarded this bugzilla entry to netdev
an I applied the patch a few days ago.
