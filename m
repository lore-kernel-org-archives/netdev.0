From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: bnx2 dirver's firmware images
Date: Tue, 18 Sep 2007 11:41:34 -0700
Message-ID: <46F01BDE.6020902@zytor.com>
References: <200709181823.26429.vda.linux@googlemail.com>	<1190141114.9540.216.camel@dell> <20070918.112337.74737433.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:35763 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721AbXIRSlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 14:41:50 -0400
In-Reply-To: <20070918.112337.74737433.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> 
> I don't like it because it means people have to setup full initrd's
> in order to do network booting with such network cards.
> 

klibc could help with that, if there is interest in exploring that
avenue again.

	-hpa
