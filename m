From: David Miller <davem@davemloft.net>
Subject: Re: [SELinux]: selinux_socket_getpeersec_dgram() compile fix
Date: Sat, 05 Aug 2006 13:16:55 -0700 (PDT)
Message-ID: <20060805.131655.02275931.davem@davemloft.net>
References: <20060805115620.GO14627@postel.suug.ch>
	<200608051612.52528.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, cxzhang@watson.ibm.com, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21917
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751234AbWHEUQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 16:16:46 -0400
To: paul.moore@hp.com
In-Reply-To: <200608051612.52528.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>
Date: Sat, 5 Aug 2006 16:12:51 -0400

> On Saturday 05 August 2006 7:56 am, Thomas Graf wrote:
> > Collision between "[NetLabel]: SELinux support"  and
> > "[AF_UNIX]: Kernel memory leak fix for af_unix datagram getpeersec"
> >
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> I have no idea what the correct protocol is here, i.e. do I need to Ack this?  
> However, I've never "Ack'd" anything before and I figure an extra Ack won't 
> hurt anything :)
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

You don't have to, but it's nice as it adds assurance to other
reviews that the patch might be correct because someone else
thinks it is :)
