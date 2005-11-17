From: Christian <evil@g-house.de>
Subject: Re: 2.6.15-rc1: NET_CLS_U32 not working?
Date: Thu, 17 Nov 2005 16:57:14 +0100
Message-ID: <437CA85A.9090408@g-house.de>
References: <437BBC59.70301@g-house.de> <20051116235813.GS5735@stusta.de> <437BC98E.9020002@g-house.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932220AbVKQP60@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <437BC98E.9020002@g-house.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian schrieb:
> Adrian Bunk schrieb:
>>
>> I'm assuming you are trying to insert the new module in your old kernel?

yes, rebuilding the whole kernel (after just enabling NET_CLS_U32 as a 
module) makes the warnings go away.

>> This is one of the unfortunate but hardly avoidable cases where adding 
>> a module requires installing a new kernel.

i wonder why/if this is really needed. although not critical, this 
behaviour is pretty annoying....

thanks,
Christian.
-- 
BOFH excuse #24:

network packets travelling uphill (use a carrier pigeon)
