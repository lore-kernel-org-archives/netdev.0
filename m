From: David Miller <davem@davemloft.net>
Subject: Re: [SELinux]: selinux_socket_getpeersec_dgram() compile fix
Date: Sat, 05 Aug 2006 13:11:02 -0700 (PDT)
Message-ID: <20060805.131102.110983148.davem@davemloft.net>
References: <20060805115620.GO14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, cxzhang@watson.ibm.com, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37596
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932376AbWHEUKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 16:10:51 -0400
To: tgraf@suug.ch
In-Reply-To: <20060805115620.GO14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sat, 5 Aug 2006 13:56:20 +0200

> Collision between "[NetLabel]: SELinux support"  and
> "[AF_UNIX]: Kernel memory leak fix for af_unix datagram getpeersec"
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Thanks Thomas, I obviously didn't resolve that by hand properly :-/

Applied.
