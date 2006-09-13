From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 15:36:17 -0500
Message-ID: <7E7667E8-DD25-4F31-AE27-C7C2E92AC622@kernel.crashing.org>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org> <20060913195445.GH25007@electric-eye.fr.zoreil.com> <450865DB.4040809@intel.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:63086 "EHLO
	nommos.sslcatacombnetworking.com") by vger.kernel.org with ESMTP
	id S1751089AbWIMUg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 16:36:28 -0400
In-Reply-To: <450865DB.4040809@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 13, 2006, at 3:11 PM, Auke Kok wrote:

> Francois Romieu wrote:
>> Kumar Gala <galak@kernel.crashing.org> :
>>> What are good examples of simple/basic ethernet drivers one  
>>> should  use to model a new driver off of?
>> tg3/bnx2/sky2/b44/8139cp
>
> Can I add e1000/ixgb to that? ;)

What is the feeling about e100.c?

I'm looking for something that is just basic tx/rx with no real fancy  
features.

- k
