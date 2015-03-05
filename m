From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] bnx2x: Force fundamental reset for EEH recovery
Date: Thu, 05 Mar 2015 15:38:49 -0500 (EST)
Message-ID: <20150305.153849.1655091847908709969.davem@davemloft.net>
References: <201503041410.t24EAAix006027@d03av03.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org,
	cascardo@linux.vnet.ibm.com, stable@vger.kernel.org
To: brking@linux.vnet.ibm.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <201503041410.t24EAAix006027@d03av03.boulder.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Brian King <brking@linux.vnet.ibm.com>
Date: Wed, 04 Mar 2015 08:09:44 -0600

> EEH recovery for bnx2x based adapters is not reliable on all Power
> systems using the default hot reset, which can result in an
> unrecoverable EEH error. Forcing the use of fundamental reset
> during EEH recovery fixes this.
> 
> Cc: stable<stable@vger.kernel.org>
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

Applied, thanks Brian.
