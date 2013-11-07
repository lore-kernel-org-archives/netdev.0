From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] qeth: avoid buffer overflow in snmp ioctl
Date: Thu, 07 Nov 2013 03:02:45 -0500 (EST)
Message-ID: <20131107.030245.1522434774127686981.davem@davemloft.net>
References: <20131106080452.GA46718@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20131106080452.GA46718@tuxmaker.boeblingen.de.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Wed, 6 Nov 2013 09:04:52 +0100

> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> Check user-defined length in snmp ioctl request and allow request
> only if it fits into a qeth command buffer.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> Reviewed-by: Heiko Carstens <heicars2@linux.vnet.ibm.com>
> Reported-by: Nico Golde <nico@ngolde.de>
> Reported-by: Fabian Yamaguchi <fabs@goesec.de>
> Cc: <stable@vger.kernel.org>

Applied.
