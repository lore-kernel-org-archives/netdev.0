From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [IPROUTE2] Update various classifiers' help output for
	expected CLASSID syntax
Date: Wed, 13 Feb 2008 08:52:10 +0000
Message-ID: <20080213085210.GD2542@ff.dom.local>
References: <20080212215125.8241.97112.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:45413 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754064AbYBMIo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 03:44:59 -0500
Received: by fk-out-0910.google.com with SMTP id z23so5245917fkz.5
        for <netdev@vger.kernel.org>; Wed, 13 Feb 2008 00:44:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080212215125.8241.97112.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-02-2008 22:51, PJ Waskiewicz wrote:
> This updates the help output to specify that CLASSID should be hexidecimal.
...
> +	fprintf(stderr, "\nNOTE: CLASSID is parsed as hexidecimal input.\n");

s/hexidecimal/hexadecimal/g (?)

Regards,
Jarek P.
