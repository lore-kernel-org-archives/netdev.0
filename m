From: Ben Greear <greearb@candelatech.com>
Subject: Re: NAPI 8139too.c for 2.4.23
Date: Mon, 01 Dec 2003 15:39:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FCBD120.7070207@candelatech.com>
References: <20031201205038.GK10711@ovh.net> <20031201205533.GA15846@gtf.org> <20031201230013.GM4313@ovh.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Octave <oles@ovh.net>
In-Reply-To: <20031201230013.GM4313@ovh.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Octave wrote:
>>Is there any chance you could do some benchmark runs with ttcp or
>>somesuch?
> 
> 
> I tested on 6-7 servers running with 
> eepro eth0: Intel Corp. 82557/8/9 [Ethernet Pro 100], 00:E0:18:01:78:6C, IRQ 10.
> realtek 8139too with NAPI 8139too Fast Ethernet driver 0.9.27 
> realtek 8139too with no NAPI (standard driver with soft polling)
> 
> If this quick test is correct, realtek 8139too's driver works as good as
> eepro's driver. 
> 
> Octave 

Those are some nice numbers!  I may have to bring some of my $5 realteks out of
retirement!  Anyone make a 4-port NIC with realteks on it?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
