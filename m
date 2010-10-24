From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/12] ipconfig: make local variables/function static
Date: Sun, 24 Oct 2010 15:06:37 -0700 (PDT)
Message-ID: <20101024.150637.183042113.davem@davemloft.net>
References: <20101021175045.625707607@vyatta.com>
	<20101021175148.504406585@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932938Ab0JXWGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 18:06:14 -0400
In-Reply-To: <20101021175148.504406585@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


git grep ic_set_manually -- arch/sparc
