From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 1/5 ibmveth fix bonding
Date: Wed, 26 Oct 2005 00:11:23 -0400
Message-ID: <435F01EB.6080608@pobox.com>
References: <1130275458.10524.425.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932532AbVJZELa@vger.kernel.org>
To: Santiago Leon <santil@us.ibm.com>
In-Reply-To: <1130275458.10524.425.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Santiago Leon wrote:
> This patch updates dev->trans_start and dev->last_rx so that the ibmveth
> driver can be used with the ARP monitor in the bonding driver. 
> 
> Signed-off-by: Santiago Leon <santil@us.ibm.com>

all patches look OK to me.

all patches except #1 appear to be whitespace-corrupted.

	Jeff
