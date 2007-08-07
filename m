From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch] sis190 check for ISA bridge on SiS966
Date: Tue, 07 Aug 2007 17:19:06 -0400
Message-ID: <46B8E1CA.8010002@pobox.com>
References: <20070801155204.GB21942@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neil Muller <drnlmuller+bugs@gmail.com>
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937003AbXHGVTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 17:19:11 -0400
In-Reply-To: <20070801155204.GB21942@stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

maximilian attems wrote:
> From: Neil Muller <drnlmuller+bugs@gmail.com>
> 
> sis190 driver assumes to find ISA only on SiS965.
> similar fix is in sis900 driver, see bug report
> http://bugs.debian.org/435547
> 
> Signed-off-by: maximilian attems <max@stro.at>

applied to #upstream-fixes


