From: Venkata Jagana <jaganav@us.ibm.com>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Fri, 30 May 2003 13:38:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED7C129.2000800@us.ibm.com>
References: <20030424132559.GA15894@morphine.tml.hut.fi>	<Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi> <20030531.000319.114704530.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   lpetande@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030531.000319.114704530.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When we have tested this recently (just two months ago), we found only 
two bugs but MIPL has already fixed those in their development version. 
How long before have you tested this and what problems have you 
encountered in your test?

Thanks,
Venkat

YOSHIFUJI Hideaki /  wrote:

>In article <Pine.LNX.4.44.0305301712300.3584-200000@rhea.tcs.hut.fi> (at Fri, 30 May 2003 17:34:40 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:
>
>  
>
>>here is a patch that fixes CONFIG_IPV6_SUBTREES and allows overriding
>>normal routes with source address specific ones. This is for example
>>needed in MIPv6 for handling the traffic to and from a mobile node's home
>>address correctly.
>>    
>>
>
>Let us test the patch.  It seemed buggy when USAGI tested before.
>
>  
>
