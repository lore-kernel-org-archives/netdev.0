From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CONNECTOR: add a proc entry to list connectors
Date: Mon, 23 Jun 2008 18:45:57 -0700 (PDT)
Message-ID: <20080623.184557.72075822.davem@davemloft.net>
References: <48604E44.5040402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	johnpol@2ka.mipt.ru
To: lizf@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40225
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752335AbYFXBp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 21:45:57 -0400
In-Reply-To: <48604E44.5040402@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zefan <lizf@cn.fujitsu.com>
Date: Tue, 24 Jun 2008 09:30:44 +0800

> I got a problem when I wanted to check if the kernel supports process
> event connector, and It seems there's no way to do this check.

Try to create a connector socket.
