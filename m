From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 15:00:07 -0800
Message-ID: <424C80F7.3090901@candelatech.com>
References: <424C6089.1080507@candelatech.com> <1112303627.1073.71.camel@jzny.localdomain> <424C6B10.6030200@candelatech.com> <1112306031.1073.109.camel@jzny.localdomain> <424C7813.4000101@candelatech.com> <20050331224640.GC3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050331224640.GC3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Ben Greear <424C7813.4000101@candelatech.com> 2005-03-31 14:22
> 
>>My personal opinion is that netlink sockets are a pain in the ass to deal
>>with, and there is no way I want to try to programatically parse the tc
>>input or output.
> 
> 
> libnl will make your life a lot easier, the tc support is not yet
> finished but I'll be releasing a version this week which at least
> fully support all the basics (link, neigh, address, routes, rules).
> It's only a matter of time until one can use the tc interface with
> only a few library calls.

Sometime I will revisit netlink.  There are some things I want to do
like allowing more than 8 bits of routing tables, and perhaps watching
for network link up/down events and the like.  Please don't bust ass to support
tc on my account as it's quite unlikely I'll use it any time soon.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
