From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] remove if_port_text
Date: Thu, 29 May 2003 14:48:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.144853.88480047.davem@redhat.com>
References: <20030529.140828.78714529.davem@redhat.com>
	<20030529142820.5f657d77.shemminger@osdl.org>
	<3ED67E01.6060906@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <3ED67E01.6060906@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Thu, 29 May 2003 17:39:13 -0400

   Stephen Hemminger wrote:
   > Eliminate necrophilic code, net-sysfs shouldn't support
   > deprecated if_port.  Since nowhere else is using if_port_text,
   > eliminate it.
   
   Looks good to me...  David?
   
I'm fine with it.  I'll apply to 2.5.x

Jeff what do you think about 2.4.x?
