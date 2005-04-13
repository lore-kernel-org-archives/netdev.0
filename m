From: George Anzinger <george@mvista.com>
Subject: Re: [PATCH] Maintainers list update: linux-net -> netdev
Date: Wed, 13 Apr 2005 15:42:27 -0700
Message-ID: <425DA053.8020607@mvista.com>
References: <20050412062027.GA1614@verge.net.au> <425C1E30.5060405@mvista.com> <20050413021400.GA1835@verge.net.au>
Reply-To: george@mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Pavel Machek <pavel@ucw.cz>, Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261203AbVDMWo0@vger.kernel.org>
To: Horms <horms@verge.net.au>
In-Reply-To: <20050413021400.GA1835@verge.net.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Horms wrote:
> On Tue, Apr 12, 2005 at 12:14:56PM -0700, George Anzinger wrote:
> 
>>Horms wrote:
>>
>>>Use netdev as the mailing list contact instead of the mostly dead
>>>linux-net list.
>>>
>>
>>~
>>
>>>PHRAM MTD DRIVER
>>>@@ -1795,7 +1795,7 @@
>>>POSIX CLOCKS and TIMERS
>>>P:	George Anzinger
>>>M:	george@mvista.com
>>>-L:	linux-net@vger.kernel.org
>>>+L:	netdev@oss.sgi.com
>>>S:	Supported
>>>
>>
>>I don't really know about the rest of them, but I think this should be:
>>L: linux-kernel@vger.kernel.org
>>
>>Least wise that is where I look...
> 
> 
> Yes, I was wondering about that one. Here is a patch that
> adds to my previous patch. Trivial to say the least. 
> I can re-diff the whole thing if that is more convenient.

Looks good to me.
> 

-- 
George Anzinger   george@mvista.com
High-res-timers:  http://sourceforge.net/projects/high-res-timers/
