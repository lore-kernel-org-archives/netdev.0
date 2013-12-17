From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v4 3/3] packet: deliver VLAN TPID to userspace
Date: Tue, 17 Dec 2013 15:10:41 +0100
Message-ID: <52B05B61.9020200@redhat.com>
References: <87d2kv7fdn.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	David Laight <David.Laight@ACULAB.COM>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52661 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab3LQOKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 09:10:51 -0500
In-Reply-To: <87d2kv7fdn.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2013 02:53 PM, Atzm Watanabe wrote:
> This enables userspace to get VLAN TPID as well as the VLAN TCI.
>
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>

Acked-by: Daniel Borkmann <dborkman@redhat.com>

Looks good, imho.

Maybe, later on in a follow-up you could also update
Documentation/networking/packet_mmap.txt in places
related to vlan bits, so that people are aware of this.
