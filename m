From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Mon, 09 Jun 2003 13:09:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE4BF39.2020503@pobox.com>
References: <20030607191522.GB3346@gtf.org>	<20030607.235825.71096085.davem@redhat.com>	<3EE4045D.4040002@pobox.com> <20030608.225309.39172149.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030608.225309.39172149.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
>    From: Jeff Garzik <jgarzik@pobox.com>
>    Date: Sun, 08 Jun 2003 23:51:57 -0400
> 
>    David S. Miller wrote:
>    > Have you extracted out all the init_etherdev() killings Al and
>    > myself did so you can backport them to 2.4.x too?
>    
>    That's the plan, yes.
>    
> That's your plan, but did you do any of this yet?  It'll keep
> going deeper and deeper into bitkeeper history the longer that
> you wait :-)


Yes, I have been following my plan.  You will see when Marcelo opens 
2.4.22-pre1 that I have been committing these to my net-drivers-2.4 queue.

	Jeff
