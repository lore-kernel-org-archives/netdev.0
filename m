From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH v2 2/3] ixgbevf: Set rx hash type for
	ingress packets
Date: Wed, 6 May 2015 22:45:48 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E17F8289C9@ORSMSX108.amr.corp.intel.com>
References: <1430276261-29821-1-git-send-email-fan.du@intel.com>
 <1430276261-29821-3-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Du, Fan" <fan.du@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Du, Fan" <fan.du@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:54192 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751638AbbEFWpt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 18:45:49 -0400
In-Reply-To: <1430276261-29821-3-git-send-email-fan.du@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Fan Du
> Sent: Tuesday, April 28, 2015 7:58 PM
> To: Kirsher, Jeffrey T
> Cc: netdev@vger.kernel.org; Du, Fan; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH v2 2/3] ixgbevf: Set rx hash type for ingress
> packets
> 
> Set hash type for ingress packets according to NIC advanced receive descriptors
> RSS type part.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/defines.h      |   12 +++++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   27
> +++++++++++++++++++++
>  2 files changed, 39 insertions(+), 0 deletions(-)

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
