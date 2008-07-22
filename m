From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Tue, 22 Jul 2008 19:31:42 -0400
Message-ID: <48866DDE.9080201@garzik.org>
References: <12163522333496-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: m.kozlowski@tuxland.pl, bhutchings@solarflare.com,
	adobriyan@gmail.com, yjwei@cn.fujitsu.com, rdreier@cisco.com,
	shemminger@vyatta.com, davem@davemloft.net, jcliburn@gmail.com,
	parag.warudkar@gmail.com, w@1wt.eu,
	oliver.schuster@schweigstill.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48094 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758310AbYGVXcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 19:32:23 -0400
In-Reply-To: <12163522333496-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jie.yang@atheros.com wrote:
> From: Jie Yang <jie.yang@atheros.com>
> 
> Full patch for the Atheros L1E Gigabit Ethernet driver.
> Supportring AR8121, AR8113 and AR8114
> 
> Signed-off-by: Jie Yang <jie.yang @atheros.com>
> ---
> update on comments:
> 	1) Remove dup MACRO already defined in linux/ethtool.h
> 	2) Remove pci_using_64 logic for the reason as atl1
> 

applied


