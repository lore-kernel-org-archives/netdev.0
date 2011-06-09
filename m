From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: Request for review on Hyper-V virtual network driver
Date: Thu, 9 Jun 2011 22:00:04 +0000
Message-ID: <A1F3067C9B68744AA19F6802BAB8FFDC09603E9D@TK5EX14MBXC227.redmond.corp.microsoft.com>
References: <1307654865-30326-1-git-send-email-haiyangz@microsoft.com>
 <20110609145641.cf245229.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hank Janssen <hjanssen@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	"gregkh@suse.de" <gregkh@suse.de>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.microsoft.com ([131.107.115.214]:18642 "EHLO
	smtp.microsoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756206Ab1FIWAF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 18:00:05 -0400
In-Reply-To: <20110609145641.cf245229.randy.dunlap@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Randy Dunlap [mailto:randy.dunlap@oracle.com]
> Sent: Thursday, June 09, 2011 5:57 PM
> > +config HYPERV_NET
> > +	tristate "Microsoft Hyper-V virtual network driver"
> > +	depends on NET
> 
> Drop line above -- it's no longer needed since drivers/net/Kconfig
> handles that.

Will do.

Thanks,
- Haiyang
