From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: smatch stuff: use after free bug
Date: Mon, 28 Mar 2011 12:34:41 +0000
Message-ID: <953B660C027164448AE903364AC447D20705EEB2@mtldag01.mtl.com>
References: <20110328103140.GJ1885@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:36748 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753360Ab1C1Met convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 08:34:49 -0400
In-Reply-To: <20110328103140.GJ1885@bicker>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: smatch stuff: use after free bug
> 
> Smatch complains about this.  It's not obvious to me how to fix it.
> The
> bug was introduced in b12d93d63 "mlx4: Add support for promiscuous mode
> in the new steering model.".

Thanks,
Will send a fix.

Yevgeny
