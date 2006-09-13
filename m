From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: examples to model ethernet driver off of?
Date: Wed, 13 Sep 2006 13:11:07 -0700
Message-ID: <450865DB.4040809@intel.com>
References: <9F51F56C-9924-4DEC-A823-892DDEE69131@kernel.crashing.org> <20060913195445.GH25007@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39603 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1751161AbWIMUNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 16:13:51 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060913195445.GH25007@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Kumar Gala <galak@kernel.crashing.org> :
>> What are good examples of simple/basic ethernet drivers one should  
>> use to model a new driver off of?
> 
> tg3/bnx2/sky2/b44/8139cp

Can I add e1000/ixgb to that? ;)

Cheers,

Auke
