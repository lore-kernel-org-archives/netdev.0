From: Ben Greear <greearb@candelatech.com>
Subject: Re: Submission #3  for S2io 10GbE driver
Date: Tue, 02 Mar 2004 14:21:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404508EC.8060200@candelatech.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222A08E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E010222A08E@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:
>>Let's fix the broken drivers first.
> 
> 
> Ok, e100 v3 is same model as tg3, and we think tg3 is correct, so we
> think e100 v3 is correct as well.
> 
> Ben, e100 v3 probably isn't given you the effect you had with previous
> driver versions.  It'll stop the queue and never return a skb (unless we
> hit that BUG case).

Ok.  Since I can retry it's not a big problem anyway.  I'm porting
stuff forward to 2.6 and will re-test there sometime soon.

> e1000/ixgb need some work to bring them into this model.

Cool, looking forward to it!

Ben

> 
> -scott
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
