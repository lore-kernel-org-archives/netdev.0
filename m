From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: [PATCH 0/2] Sysfs net class .
Date: Mon, 19 May 2003 15:46:35 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030519154502.D39024@shell.cyberus.ca>
References: <20030513150303.A2406@DYN318281.beaverton.ibm.com>
 <200305131657.03508.dsteklof@us.ibm.com> <20030514142023.0e411f34.shemminger@osdl.org>
 <200305141443.57169.dsteklof@us.ibm.com> <20030515162712.61cd153e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, Patrick Mochel <mochel@osdl.org>,
   netdev@oss.sgi.com, greg@kroah.com, jkenisto@us.ibm.com,
   lkessler@us.ibm.com, Daniel Stekloff <dsteklof@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030515162712.61cd153e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi Stephen,

Not too familiar with sysfs but make sure it doesnt break netlink or
even ioctl. BTW, did i misread that or are you allowing restoring things
like ifindex in that patch?

cheers,
jamal
