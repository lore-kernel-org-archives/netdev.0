From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH] irlan: fix header build warning
Date: Thu, 7 Dec 2006 00:57:50 +0200
Message-ID: <20061206225750.GA17679@sortiz.org>
References: <20061206114407.9b835a7a.randy.dunlap@oracle.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.orange.fr ([193.252.22.26]:38840 "EHLO
	smtp-msa-out05.orange.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S937763AbWLFW5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 17:57:53 -0500
To: Randy Dunlap <randy.dunlap@oracle.com>
Content-Disposition: inline
In-Reply-To: <20061206114407.9b835a7a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

Thanks for the patch. Looks fine to me.

On Wed, Dec 06, 2006 at 11:44:07AM -0800, Randy Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix compile warning when CONFIG_PROC_FS=n:
> 
> include/net/irda/irlan_filter.h:31: warning: 'struct seq_file' declared inside parameter list
> include/net/irda/irlan_filter.h:31: warning: its scope is only this definition or declaration, which is probably not what you want
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

Cheers,
Samuel.
