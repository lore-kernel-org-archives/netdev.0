From: Terry <hanfang@baidu.com>
Subject: Re: [PATCHv2 1/2] [NET] add skb_recycle_check() to enable netdriver
 skb recycling
Date: Wed, 08 Oct 2008 09:24:54 +0800
Message-ID: <48EC0BE6.5020203@baidu.com>
References: <20080928204633.GB19070@xi.wantstofly.org> <20080928213824.GA25298@2ka.mipt.ru> <20080928215035.GG19070@xi.wantstofly.org> <20080929053931.GB21663@2ka.mipt.ru> <20080929094650.GA26097@xi.wantstofly.org> <36D9DB17C6DE9E40B059440DB8D95F52064B198F@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.baidu.com.163.135.61.in-addr.arpa ([61.135.163.61]:53082
	"HELO smtp.baidu.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1752560AbYJHBbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 21:31:36 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52064B198F@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Brandeburg, Jesse wrote:
> Lennert Buytenhek wrote:
>   
>> Could you (or anyone else) try this patch on one of your boxes and
>> see what kind of effect it has on performance?
>>     
>
> Lennert, we're very interested in this kind of work, and I'll see what
> we can come up with by porting ixgbe or igb to use the patch.  Bad news
> is it may be as far away as a couple of weeks, because of this e1000e
> corrupt NVM thing I'm working on.
>
>   
ixgbe's skb recycle patch means a lot to me :-)

Terry

