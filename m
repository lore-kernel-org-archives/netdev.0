From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Sun, 08 Jun 2003 23:51:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE4045D.4040002@pobox.com>
References: <20030606145835.3a263df8.shemminger@osdl.org>	<20030607191522.GB3346@gtf.org> <20030607.235825.71096085.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030607.235825.71096085.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Have you extracted out all the init_etherdev() killings Al and
> myself did so you can backport them to 2.4.x too?

That's the plan, yes.

	Jeff
