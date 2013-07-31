From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] tcp: Remove unused tcpct declarations and comments
Date: Wed, 31 Jul 2013 12:16:56 -0700 (PDT)
Message-ID: <20130731.121656.1536518989145765329.davem@redhat.com>
References: <20130731133945.5b7b3f7487491f41ea45a7f6@highloadlab.com>
	<20130731110821.GA3747@cpaasch-mac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dp@highloadlab.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, edumazet@google.com,
	ncardwell@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: christoph.paasch@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130731110821.GA3747@cpaasch-mac>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Paasch <christoph.paasch@gmail.com>
Date: Wed, 31 Jul 2013 13:08:21 +0200

> On 31/07/13 - 13:39:45, Dmitry Popov wrote:
>> Remove declaration, 4 defines and confusing comment that are no longer used
>> since 1a2c6181c4 ("tcp: Remove TCPCT").
>> 
>> Signed-off-by: Dmitry Popov <dp@highloadlab.com>
>> ---
>>  include/linux/tcp.h | 1 -
>>  include/net/tcp.h   | 4 ----
>>  net/ipv4/tcp.c      | 4 ----
>>  3 files changed, 9 deletions(-)
> 
> Sorry, I oversaw these when removing TCPCT.
> 
> Acked-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, thanks.
