From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [net-next] ixgbe: Add module parameter to allow untested and
 unsafe SFP+ modules
Date: Wed, 01 Feb 2012 20:35:16 +0100
Message-ID: <1328124916.12731.0.camel@probook>
References: <1328123961-17237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:50767 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab2BATfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:35:19 -0500
In-Reply-To: <1328123961-17237-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-02-01 at 11:19 -0800, Jeff Kirsher wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> The X520 family of network devices, with the 82599 chip, support a
> small number of Intel-verified SFP+ modules on their NICs.  To maintain
> stability and quality, the current devices restrict untested 3rd party
> SFP+ modules.
> 
> This patch introduces a module parameter for ixgbe to allow these untested
> modules at the user's peril.  It also includes a warning to the syslog
> alerting users that the modules aren't supported, and results may
> vary.
> 
> CC: Jesper Dangaard Brouer <hawk@comx.dk>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Acked-by: Jesper Dangaard Brouer <hawk@comx.dk>
