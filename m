From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
Date: Tue, 5 May 2015 17:25:56 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DBE9D2@ORSMSX101.amr.corp.intel.com>
References: <1429302240-654-1-git-send-email-jtoppins@cumulusnetworks.com>
 <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Alan Liebthal <alanl@cumulusnetworks.com>
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:57360 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932927AbbEER0A convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:26:00 -0400
In-Reply-To: <1429302240-654-2-git-send-email-jtoppins@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jonathan Toppins
> Sent: Friday, April 17, 2015 1:24 PM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
> C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; gospo@cumulusnetworks.com;
> shm@cumulusnetworks.com; Alan Liebthal
> Subject: [PATCH v1 net-next 2/2] igb: support SIOCSMIIREG
> 
> From: Alan Liebthal <alanl@cumulusnetworks.com>
> 
> Support setting the MII register via SIOCSMIIREG.
> 
> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    5 +++++
>  1 file changed, 5 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
