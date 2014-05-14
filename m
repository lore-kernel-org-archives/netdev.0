From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Wed, 14 May 2014 16:10:38 -0400 (EDT)
Message-ID: <20140514.161038.604524051618558919.davem@redhat.com>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com>
	<20140513.183145.1568789082256942703.davem@davemloft.net>
	<20140514080557.GB9848@osiris>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, hpa@zytor.com,
	dborkman@redhat.com, netdev@vger.kernel.org, schwidefsky@de.ibm.com
To: heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbaENUKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 16:10:47 -0400
In-Reply-To: <20140514080557.GB9848@osiris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Wed, 14 May 2014 10:05:57 +0200

> Dave, can you route this via -net?

Done.
