From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: Ethernet driver for the WIZnet W5100 chip
Date: Tue, 10 Apr 2012 02:08:00 -0700 (PDT)
Message-ID: <4da79b69-e114-4806-9452-2f58e2aad8b9@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <msink@permonline.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:18821 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab2DJJIG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 05:08:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same issue is there in w5300_hw_probe() as well.

regards,
dan carpenter
