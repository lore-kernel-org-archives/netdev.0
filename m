From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax: fix typo in kernel-doc for debugfs_dentry in
 struct wimax_dev
Date: Fri, 09 Jan 2009 23:09:23 -0800 (PST)
Message-ID: <20090109.230923.186059441.davem@davemloft.net>
References: <4966E268.20101@oracle.com>
	<1231522440-30059-1-git-send-email-inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org,
	randy.dunlap@oracle.com
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753554AbZAJHJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 02:09:23 -0500
In-Reply-To: <1231522440-30059-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Fri,  9 Jan 2009 09:34:00 -0800

> The kernel-doc was referring to member @debufs_dentry instead of
> @debugfs_dentry.
> 
> Reported by Randy Dunlap http://marc.info/?l=linux-netdev&m=123147942302885&w=2
> 
> As well, escape the colon in the field's text description, as it is
> causing the generated text to be erraticly broken up (with paragraphs
> moved down). Could not find a reason why it is happening so, even when
> other field descriptions use colons and work as expected.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied.
