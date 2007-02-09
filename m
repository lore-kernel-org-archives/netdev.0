From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][RESEND] gianfar: Convert network devices to use struct
 device instead of class_device
Date: Fri, 09 Feb 2007 16:10:47 -0500
Message-ID: <45CCE357.3030203@pobox.com>
References: <Pine.LNX.4.64.0702081118090.29779@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60267 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423209AbXBIVKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:10:51 -0500
In-Reply-To: <Pine.LNX.4.64.0702081118090.29779@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> Convert network devices to use struct device instead of class_device.  Greg
> missed this one in his cleanup path.
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>

OK, but doesn't apply to torvalds/linux-2.6.git ...

	Jeff



