From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: (usagi-users 03019) Re: sysctl net.ipv6.conf.eth0.use_tempaddr
 only recogniced on interface start?
Date: Thu, 10 Feb 2005 22:33:41 +0200 (EET)
Message-ID: <Pine.LNX.4.61.0502102232400.4885@netcore.fi>
References: <F5812425CD96109163291692@worker.muc.bieringer.de>
 <20040830.180805.06423987.yoshfuji@linux-ipv6.org>
 <83D85B170EFC0F1C0451F2EB@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <83D85B170EFC0F1C0451F2EB@worker.muc.bieringer.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2005, Peter Bieringer wrote:
>> a
>>
>> and even b; we can probably extend our implementation
>> to create temprary address when net.ipv6.conf.eth0.use_tempaddr is
>> changed  from 0 to 1.
>
> Any news on that? Have you plans to implement it?

Speaking of which, it would REALLY useful to implement the similar 
"state change triggers" for e.g. accept_ra (which would send out a RS 
immediately, which is currently impossible from the user space).

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
