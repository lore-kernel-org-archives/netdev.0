From: Joe Perches <joe@perches.com>
Subject: Re: [net  8/8] i40e: include i40e in kernel proper
Date: Wed, 11 Sep 2013 05:20:02 -0700
Message-ID: <1378902002.606.42.camel@joe-AO722>
References: <1378893056-4821-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1378893056-4821-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0021.hostedemail.com ([216.40.44.21]:52999 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751640Ab3IKMUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 08:20:05 -0400
In-Reply-To: <1378893056-4821-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 02:50 -0700, Jeff Kirsher wrote:
> New driver build option is CONFIG_I40E

> diff --git a/Documentation/networking/00-INDEX b/Documentation/networking/00-INDEX
[]
> +i40e.txt
> +	- README for the Intel Ethernet Controller XL710 Driver (i40e).

Just curious but why the XL710 / i40e name mismatch?
