From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Tulip endianess fix
Date: Sun, 21 Mar 2004 12:40:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405DD386.6080109@pobox.com>
References: <Pine.LNX.4.58.0403202337010.20260@portland.hansa.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <Pine.LNX.4.58.0403202337010.20260@portland.hansa.lan>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pavel Roskin wrote:
> Hello!
> 
> My tulip ethernet card doesn't work on Blue&White G3 PowerMac with Linux
> 2.6.5-rc2.  The card is shown by lspci as
> 
> 01:03.0 Ethernet controller: Linksys Network Everywhere Fast Ethernet
> 10/100 model NC100 (rev 11)
> 
> The kernel detects it as "ADMtek Comet rev 17".

Looks OK at first glance.  I'll look again after caffeine and (probably) 
apply.

	Jeff
