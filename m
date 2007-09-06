From: maximilian attems <max@stro.at>
Subject: Re: dgrs: sparse warnings
Date: Thu, 6 Sep 2007 15:30:38 +0200
Message-ID: <20070906133038.GI16317@baikonur.stro.at>
References: <20070906135547.13bb3326@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro@ftp.linux.org.uk>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:1026 "EHLO baikonur.stro.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754342AbXIFNbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 09:31:11 -0400
Content-Disposition: inline
In-Reply-To: <20070906135547.13bb3326@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 06, 2007 at 01:55:47PM +0100, Stephen Hemminger wrote:
> The dgrs driver is crap and assumes direct access to PCI iomem.
> 

dgrs wants to be removed, it has no users.
(no bug report in bugzilla nor in debian nor in google)
the firmware is not distrutable.

i'll resend my removal patch bzipped and attached.

-- 
maks
