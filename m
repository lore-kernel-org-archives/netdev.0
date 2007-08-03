From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] lro: myri10ge example how to use LRO
Date: Fri, 03 Aug 2007 17:00:36 -0400
Message-ID: <46B39774.4050909@myri.com>
References: <46B363A8.4010407@myri.com> <46B39063.6070301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com,
	jeff@garzik.org, davem@davemloft.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763933AbXHCVBW@vger.kernel.org>
In-Reply-To: <46B39063.6070301@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Andrew Gallatin wrote:
>> To follow up on Jan-Bernd Themann's LRO patch earlier today,
>> this patch shows how the generic LRO interface can be used for
>> page based drivers.
>>
>> Again, many thanks to Jan-Bernd Themann for leading this effort.
>>
>> Drew
>>
>> Singed off by: Andrew Gallatin <gallatin@myri.com>
>>
> 
> 
> please take a look at my lro patch for ethtool and see if it works for 
> you, instead of adding another generic module parameter that doesn't 
> need to be there.

That looks very nice, and will indeed work for me.

Thanks,

Drew
