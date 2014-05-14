From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2 net] net: filter: x86: fix JIT address randomization
Date: Wed, 14 May 2014 13:40:31 -0700
Message-ID: <5373D4BF.1040002@zytor.com>
References: <1400018755-3049-1-git-send-email-ast@plumgrid.com>	<20140513.183145.1568789082256942703.davem@davemloft.net>	<20140514080557.GB9848@osiris> <20140514.161038.604524051618558919.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, dborkman@redhat.com,
	netdev@vger.kernel.org, schwidefsky@de.ibm.com
To: David Miller <davem@redhat.com>, heiko.carstens@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:59682 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbaENUkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 16:40:52 -0400
In-Reply-To: <20140514.161038.604524051618558919.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2014 01:10 PM, David Miller wrote:
> From: Heiko Carstens <heiko.carstens@de.ibm.com>
> Date: Wed, 14 May 2014 10:05:57 +0200
> 
>> Dave, can you route this via -net?
> 

Pardon for being a bit confused, but it would seem x86 or net would be
the logical routes for this -- I don't mind at all it being routed
through net, but that would seem to be between myself (and the other x86
maintainers) and Dave...
	
	-hpa
