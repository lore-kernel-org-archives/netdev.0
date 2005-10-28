From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] ibmveth fix bonding
Date: Fri, 28 Oct 2005 16:07:54 -0400
Message-ID: <4362851A.2070108@pobox.com>
References: <20051026164532.21820.72673.sendpatchset@localhost.localdomain> <20051026164539.21820.57374.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030272AbVJ1UIE@vger.kernel.org>
To: Santiago Leon <santil@us.ibm.com>
In-Reply-To: <20051026164539.21820.57374.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Santiago Leon wrote:
> This patch updates dev->trans_start and dev->last_rx so that the ibmveth
> driver can be used with the ARP monitor in the bonding driver. 
> 
> Signed-off-by: Santiago Leon <santil@us.ibm.com>

applied 1-5
