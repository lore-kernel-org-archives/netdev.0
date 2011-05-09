From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: slip, fix ldisc->open retval
Date: Mon, 09 May 2011 11:53:18 -0700 (PDT)
Message-ID: <20110509.115318.39190498.davem@davemloft.net>
References: <BANLkTinWqaoMNHbOb5PbZzewQafWhBfY4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab1EISxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 14:53:50 -0400
In-Reply-To: <BANLkTinWqaoMNHbOb5PbZzewQafWhBfY4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Fri, 6 May 2011 20:23:09 +0400

> TTY layer expects 0 if the ldisc->open operation succeeded.
> 
> Signed-off-by : Matvejchikov Ilya <matvejchikov@gmail.com>

Applied, thank you.
