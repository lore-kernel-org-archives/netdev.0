From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] Add ethtool -i interface to Prism54
Date: Sat, 21 Oct 2006 14:19:29 -0400
Message-ID: <453A64B1.7050900@garzik.org>
References: <4536D5EE.4060405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:27372 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1423377AbWJUSTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2006 14:19:31 -0400
To: Kai Engert <kengert@redhat.com>
In-Reply-To: <4536D5EE.4060405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kai Engert wrote:
> Attached is a small patch that will add support for
>  ethtool -i
> to the prism54 driver.
> 
> ethtool -i queries the specified ethernet device for associated driver 
> information.
> 
> This helps tools like Fedora's system-config-network to provide GUI 
> management of network devices.
> I learned how to write this patch by reading the ipw2100 driver code.
> 
> Thanks for considering to take it.

Please include a Signed-off-by line at a minimum, to provide a legal 
release for your patch.  Other details, like including the patch inline 
rather than as an attachment can found in
http://linux.yyz.us/patch-format.html and 
Documentation/SubmittingPatches in the kernel tree.

	Jeff


