From: Ben Greear <greearb@candelatech.com>
Subject: Re: local_bh_enable & hard_start_xmit
Date: Mon, 18 Apr 2005 16:17:32 -0700
Message-ID: <4264400C.40004@candelatech.com>
References: <42642892.2040300@candelatech.com>	<20050418151421.41a8f64a.davem@davemloft.net>	<42643BB9.6050705@candelatech.com> <20050418160147.6fd7ac9a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050418160147.6fd7ac9a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Mon, 18 Apr 2005 15:59:05 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>This would be a good addition to the Documentation/networking/netdevices.txt
>>file, or maybe to the dev.c file somewhere (I haven't found an complete list of
>>locking notes, though the comments in the dev.c file and the netdevices.txt file
>>are a big help.)
> 
> 
> So write the patch to add such comments.  It would have taken the
> same amount of typing as writing that paragraph saying how great an
> addition this would be. :)

I figured it would be quicker for you to paste the paragraph than to
apply my patch :)

I'll send one over directly.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
