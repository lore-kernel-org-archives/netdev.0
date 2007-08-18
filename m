From: Tejun Heo <teheo@suse.de>
Subject: Re: [PATCH] e1000e: Update e1000e driver to use devres
Date: Sat, 18 Aug 2007 09:51:34 +0900
Message-ID: <46C64296.9050007@suse.de>
References: <20070815190014.GE7294@ifup.org> <46C43891.4080304@suse.de> <46C48B2E.9040105@intel.com> <20070817202502.GD4525@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, jgarzik@pobox.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Brandon Philips <bphilips@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jericho.provo.novell.com ([137.65.248.124]:29523 "EHLO
	jericho.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbXHRAwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 20:52:13 -0400
In-Reply-To: <20070817202502.GD4525@ifup.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Philips wrote:
> Conversion of e1000e probe() and remove() to devres.
> 
> Depends on "[patch 1/4] Update net core to use devres."
> 
> Signed-off-by: Brandon Philips <bphilips@suse.de>

Acked-by: Tejun Heo <htejun@gmail.com>

-- 
tejun
