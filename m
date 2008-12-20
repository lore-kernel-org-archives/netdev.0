From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: kernel panics with net_rx_action on kernels >2.6.26
Date: Sun, 21 Dec 2008 00:00:56 +0100
Message-ID: <200812210000.56995.rjw@sisk.pl>
References: <4944026B.40301@sbg.ac.at>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Alexander Huemer <alexander.huemer@sbg.ac.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:49692 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972AbYLTXBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 18:01:13 -0500
In-Reply-To: <4944026B.40301@sbg.ac.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(CC to netdev)

On Saturday, 13 of December 2008, Alexander Huemer wrote:
> hi,
> 
> one of my machines (x86) crashes under heavy network load with kernels
> >2.6.26, i tried quite everything possible between 2.6.27 and 2.6.28-rc8.
> 
> lspci -vv: http://xx.vu/~ahuemer/lspci_vv.txt
> of the quad nic 2 ports are used, the machine is acting as a iptables
> firewall/router.
> 
> kernel config (2.6.26) http://xx.vu/~ahuemer/config
> screenshot of the panic:
> http://xx.vu/~ahuemer/kernel_panic_net_rx_action.jpg
> 
> as i do not have any problems with kernels <=2.6.26, i doubt that this
> is a hardware problem.
> in case of the panic, nothing is written to the system log.
> 
> any hints welcome.
> please CC me on replies, i am not subscribed to the  mailing list.
> 
> thanks in advance.
