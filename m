From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 19/29] ioat1: trim ioat_dma_desc_sw
Date: Mon, 14 Sep 2009 15:55:32 +0100
Message-ID: <129600E5E5FB004392DDC3FB599660D7B5548181@irsmsx504.ger.corp.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
 <20090904023206.32667.35974.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755655AbZINO4d@vger.kernel.org>
In-Reply-To: <20090904023206.32667.35974.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Williams, Dan J wrote:
> Save 4 bytes per software descriptor by transmitting tx_cnt in an unused
> portion of the hardware descriptor.
> 
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>