From: jamal <hadi@cyberus.ca>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: 30 Mar 2005 06:55:29 -0500
Message-ID: <1112183729.1088.65.camel@jzny.localdomain>
References: <20050328123801.GY3086@postel.suug.ch>
	 <1112014261.1089.1018.camel@jzny.localdomain>
	 <20050328125802.GZ3086@postel.suug.ch>
	 <1112015725.1089.1045.camel@jzny.localdomain>
	 <20050328155523.GD3086@postel.suug.ch>
	 <1112038128.1119.5.camel@jzny.localdomain>
	 <20050328195320.GE3086@postel.suug.ch>
	 <20050328223310.GH3086@postel.suug.ch>
	 <20050329011058.GJ3086@postel.suug.ch>
	 <1112129516.1076.90.camel@jzny.localdomain>
	 <20050330010209.GN3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, netdev <netdev@oss.sgi.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050330010209.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-29 at 20:02, Thomas Graf wrote:

> So we always dump TCA_ACT_STATS when calling from tcf_exts_dump
> and add the backward compatibility TLVs in the second call
> comming from tcf_exts_dump_stats for actions that need it.
> 

Looks good from this side.

> Patches tested, works for me but might be worth for someone
> else to give it a try as well just to make sure. Meelis, could
> you give the 3 attched patches a try?
> 

Andy, can you just double check we dont have the problem you found
with stats?

cheers,
jamal
