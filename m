From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 14 Oct 2003 13:47:44 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F8C44D0.20907@sgi.com>
References: <3F844578.40306@sgi.com> <20031008101046.376abc3b.davem@redhat.com> <3F8455BE.8080300@sgi.com> <20031008183742.GA24822@wotan.suse.de> <20031008122223.1ba5ac79.davem@redhat.com> <20031008202248.GA15611@oldwotan.suse.de> <3F8702FF.70500@sgi.com> <20031010192036.GA31727@wotan.suse.de> <3F8802E6.5030601@sgi.com> <20031011131921.GC21763@wotan.suse.de>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steve Modica <modica@sgi.com>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031011131921.GC21763@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Andi Kleen wrote:
> Then just don't set the argument to zero in modules.conf on the 5704cards. 
> That could be even handled somewhere in user space.  Switching over sounds 
> best of course, because the performance with the copying won't be great

The problem with this is if you mix 5704 and 5701 cards in the same system
you are not seting it for the 5701's that need it.

John

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
