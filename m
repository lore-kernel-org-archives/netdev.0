From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.5.70] remove if_port_text
Date: Thu, 29 May 2003 17:39:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3ED67E01.6060906@pobox.com>
References: <20030529104138.751a1f54.shemminger@osdl.org>	<20030529.140828.78714529.davem@redhat.com> <20030529142820.5f657d77.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, scott.feldman@intel.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030529142820.5f657d77.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Eliminate necrophilic code, net-sysfs shouldn't support deprecated if_port.
> Since nowhere else is using if_port_text, eliminate it.

Looks good to me...  David?

	Jeff
