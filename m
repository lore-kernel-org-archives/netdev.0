From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH net-next] ixgbe: Extend trust to allow
	guest to set unicast address
Date: Wed, 13 Jan 2016 19:00:10 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180D16368@ORSMSX108.amr.corp.intel.com>
References: <1451669660-3628-1-git-send-email-3chas3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chas Williams <3chas3@gmail.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60139 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757463AbcAMTAM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2016 14:00:12 -0500
In-Reply-To: <1451669660-3628-1-git-send-email-3chas3@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Chas Williams
> Sent: Friday, January 01, 2016 9:34 AM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH net-next] ixgbe: Extend trust to allow guest to
> set unicast address
> 
> When running certain routing protocols like VRRP, VF guests need the ability to
> set the unicast address of the interface.  Extend the new ndo trust feature to let
> the hypervisor trust a guest to set/update its own unicast address.
> 
> Signed-off-by: Chas Williams <3chas3@gmail.com>
> ---

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
