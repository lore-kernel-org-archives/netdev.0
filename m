From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/5] sky2: use dev_err for error reports
Date: Wed, 31 Jan 2007 05:03:43 -0500
Message-ID: <45C0697F.2080506@garzik.org>
References: <20070126193835.658962000@linux-foundation.org> <20070126194004.223997000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55365 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932930AbXAaKDp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 05:03:45 -0500
In-Reply-To: <20070126194004.223997000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@linux-foundation.org wrote:
> Use the standard dev_printk functions instead of printk directly for
> error reports. Fix a bug where the initialization would return 0
> if allocation of network device failed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

ACK but failed to apply


