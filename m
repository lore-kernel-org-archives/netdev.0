From: linux lover <linux_lover2004@yahoo.com>
Subject: RE: how ip header added in ip_bulid_xmit function?
Date: Wed, 19 May 2004 03:36:30 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040519103630.42373.qmail@web90107.mail.scd.yahoo.com>
References: <E7AB5FC4F5C0D711B41900065BF019FB0342F9F0@rndntserver.gdnt.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxnet <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
	netfilter <netfilter-devel@lists.netfilter.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Galy Lee <galylee@gdnt.com.cn>
In-Reply-To: <E7AB5FC4F5C0D711B41900065BF019FB0342F9F0@rndntserver.gdnt.com.cn>
List-Id: netdev.vger.kernel.org




--- Galy  Lee <galylee@gdnt.com.cn> wrote:
> 
> It seems that ip_build_xmit_slow is  used to send to
> bulk data, but the
> ip_build_xmit is used to send single data packet.
> 
that mean ip_queue_xmit as well as ip_build_xmit and
ip_build_xmit_slow are all used for sending packet.
but whats difference then between all three functions?
> regards,
> linux_lover
> 
> 
> 	



	
		
__________________________________
Do you Yahoo!?
SBC Yahoo! - Internet access at a great low price.
http://promo.yahoo.com/sbc/
