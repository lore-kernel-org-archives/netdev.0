From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 0/3]qlcnic: bug fixes
Date: Wed, 27 Oct 2010 12:24:53 -0700 (PDT)
Message-ID: <20101027.122453.241932171.davem@davemloft.net>
References: <1288151589-32431-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42127
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755761Ab0J0TYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:24:30 -0400
In-Reply-To: <1288151589-32431-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Tue, 26 Oct 2010 20:53:06 -0700

>   Series v2 of 3 patches for bug fixes. Patches are numbered.
>   Dropping "dma address align check" patch as pci_alloc_consistent is gaurantee to give
>   page align dma address.

Applied, thanks.
