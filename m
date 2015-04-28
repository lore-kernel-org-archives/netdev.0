From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH v1 net-next 3/3] igb: add PHY support for Broadcom 54616
Date: Tue, 28 Apr 2015 03:22:17 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B78DBB085@ORSMSX101.amr.corp.intel.com>
References: <1428707018-6405-1-git-send-email-jtoppins@cumulusnetworks.com>
 <1428707018-6405-3-git-send-email-jtoppins@cumulusnetworks.com>
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
Received: from mga03.intel.com ([134.134.136.65]:25679 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932253AbbD1DWS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:22:18 -0400
In-Reply-To: <1428707018-6405-3-git-send-email-jtoppins@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Jonathan Toppins
> Sent: Friday, April 10, 2015 4:04 PM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Nelson, Shannon; Wyborny, Carolyn; Skidmore, Donald
> C; Vick, Matthew; Ronciak, John; Williams, Mitch A; intel-wired-
> lan@lists.osuosl.org; netdev@vger.kernel.org; gospo@cumulusnetworks.com;
> shm@cumulusnetworks.com; Alan Liebthal
> Subject: [PATCH v1 net-next 3/3] igb: add PHY support for Broadcom 54616
> 
> From: Alan Liebthal <alanl@cumulusnetworks.com>
> 
> The Celestica Redstone-XP Ethernet management port uses a Broadcom 54616
> chip for the PHY layer. This adds support for this PHY to the Intel igb
> e1000 driver.
> 
> Signed-off-by: Alan Liebthal <alanl@cumulusnetworks.com>
> Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.c   |    5 +++++
>  drivers/net/ethernet/intel/igb/e1000_defines.h |    1 +
>  drivers/net/ethernet/intel/igb/e1000_hw.h      |    1 +
>  3 files changed, 7 insertions(+)

Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Again, just regression, I do not have this phy.
