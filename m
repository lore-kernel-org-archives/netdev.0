From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 0/8] Bugfix and mechanical works for Xen
 network driver
Date: Tue, 26 Feb 2013 11:33:06 +0000
Message-ID: <1361878386.2109.42.camel@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	 <512C26F5.8020100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: ANNIE LI <annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49599 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513Ab3BZLdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 06:33:08 -0500
In-Reply-To: <512C26F5.8020100@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-26 at 03:07 +0000, ANNIE LI wrote:
> What the version are these patches based on?
> I tried v3.8-rc7 and 3.8-rc6, patch 3/8, 4/8 ... can not be merged 
> successfully. Can you rebase it?
> 

IIRC we had some XSA patches after this series. Or I just developed it
on top of a old branch. I will rebase it soon.


Wei.
