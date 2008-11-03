From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: Broken "SMC91x: delete unused local variable "lp""
Date: Mon, 3 Nov 2008 16:40:28 +0300
Message-ID: <20081103134028.GB3325@x200.localdomain>
References: <20081103133554.GA3325@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: jgarzik@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:56447 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754133AbYKCNhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 08:37:11 -0500
Received: by ey-out-2122.google.com with SMTP id 6so830419eyi.37
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2008 05:37:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081103133554.GA3325@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> drivers/net/smc91x.c:2067: error: 'lp' undeclared (first use in this function)

Oh, this is already fixed.
