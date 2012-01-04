From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3" make ethtool ops const
Date: Wed, 4 Jan 2012 14:05:09 -0800 (PST)
Message-ID: <1618043995.516880.1325714709548.JavaMail.root@zimbra-prod-mbox-5.vmware.com>
References: <20120104135813.06af6984@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:15824 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757079Ab2ADWFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 17:05:10 -0500
In-Reply-To: <20120104135813.06af6984@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> All tables of function pointers should be const to make hacks
> more difficult. Compile tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Thanks Stephen.

Acked-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
