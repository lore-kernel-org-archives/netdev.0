From: Ted Goodwin <TGoodwin@mobile-mind.com>
Subject: MAC address filtering on kernel 2.2.13
Date: Mon, 8 Apr 2002 15:14:52 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <177EEB93DEA5D4119B4800508BE753D227B6A5@FS1>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
To: "'linux-net@vger.kernel.org'" <linux-net@vger.kernel.org>
List-Id: netdev.vger.kernel.org


> Hello,
> 
> I am working on creating a MAC address packet filter for Linux kernel
> 2.2.13 .
> 
> Initially, I just want to drop all the packets whose MAC addresses aren't
> in the MAC address table.  But eventually,  the dropped packets are going
> to be allowed  to request authentication.  If successful  their MAC
> address will be added to the list.  
> 
> So my question is: What method of MAC address filtering would be easiest
> (I'm a newbie with a deadline),  appropriate, and available in the 2.2.13
> kernel? BPF? LPF? IPchains?  
> 
> Looking forward to being more helpful than a hindrance. 
> Thanks,
> Ted Goodwin
> 
> 
