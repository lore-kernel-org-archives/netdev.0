From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] add driver for enc28j60 ethernet chip
Date: Mon, 17 Dec 2007 18:49:36 -0500
Message-ID: <47670B10.5000708@pobox.com>
References: <475EA546.7030202@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34555 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761441AbXLQXti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 18:49:38 -0500
In-Reply-To: <475EA546.7030202@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

oh yeah:  make sure your Kconfig/Makefile stuff is in the _same_ patch 
as your driver.


