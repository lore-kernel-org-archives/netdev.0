From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] [ROSE] improving AX25 routing frames
Date: Sat, 12 Jul 2008 11:32:56 +0200
Message-ID: <48787A48.5030907@free.fr>
References: <200804251659.47510.bpidoux@free.fr>	<20080426.230111.49125483.davem@davemloft.net>	<4836E223.8080003@upmc.fr> <20080603.145827.170048802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080603.145827.170048802.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

You probably did not notice the following patch I re-sent a while ago at 
your request:

200806071944.07304.bpidoux () free ! fr

Although it is not critical for Linux kernel and for general users, it 
it of valuable interest for the digital hamradio community as it repairs 
the rose network routing and gives us the connectivity we are lacking.

I applied this patch to all kernel versions since it was written without 
any problem.

Could you look at it ?

Best regards,


Bernard Pidoux


David Miller wrote:
> From: "bernard.pidoux" <bernard.pidoux@upmc.fr>
> Date: Fri, 23 May 2008 17:26:27 +0200
> 
>> You may have seen that I actually condensed things by finally having 
>> incorporated the search
>> for an already connected node into existing rose_get_neigh() function.
>> This has the advantage to avoid creating a new function and not to use 
>> more spinlocks.
>> Is there any chance that you accept the patch submitted in its resulting 
>> form ?
> 
> In the time that has passed I am confused as to which of
> several pending patches I should look at and apply.
> 
> Could you simply resubmit (CC:'ing the proper lists, don't
> take discussions private like this again please) the patches
> that you think should be looked at seriously right now?
> 
> Thanks.
> 
> 
> 
