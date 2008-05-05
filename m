From: David Miller <davem@davemloft.net>
Subject: Re: Neptune regression...
Date: Mon, 05 May 2008 15:03:37 -0700 (PDT)
Message-ID: <20080505.150337.153584154.davem@davemloft.net>
References: <481F69CA.4070704@sun.com>
	<20080505.140309.128520489.davem@davemloft.net>
	<481F78D6.20704@sun.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos.Worku@Sun.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58701
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757820AbYEEWDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 18:03:37 -0400
In-Reply-To: <481F78D6.20704@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matheos Worku <Matheos.Worku@Sun.COM>
Date: Mon, 05 May 2008 14:15:02 -0700

> I actually meant the "model" property which exists on all variants.  For 
> Maramba, it  is 'SUNW,pcie-neptune'.
> The fix I have in mind  would modify the function niu_pci_vpd_get_nports 
> to use the "model" property instead of "board_model". I will test and 
> make sure the fix works on appropriate  SPARC and X86 hardware.

Aha, that makes more sense.

I look forward to seeing your patch ;-)
