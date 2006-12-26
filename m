From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] r8169: use the broken_parity_status field in pci_dev
Date: Tue, 26 Dec 2006 16:24:29 -0500
Message-ID: <4591930D.4040109@garzik.org>
References: <20061217230419.GB26485@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41391 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932794AbWLZVYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:24:31 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061217230419.GB26485@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> The former option is removed and platform code can now specify the
> expected behavior.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

applied


