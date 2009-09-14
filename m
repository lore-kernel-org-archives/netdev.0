From: "Sosnowski, Maciej" <maciej.sosnowski@intel.com>
Subject: RE: [PATCH 26/29] ioat: implement a private tx_list
Date: Mon, 14 Sep 2009 16:01:26 +0100
Message-ID: <129600E5E5FB004392DDC3FB599660D7B5548197@irsmsx504.ger.corp.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
 <20090904023242.32667.27473.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-raid@vger.kernel.org" <linux-raid@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:14457 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075AbZINPBx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 11:01:53 -0400
In-Reply-To: <20090904023242.32667.27473.stgit@dwillia2-linux.ch.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Williams, Dan J wrote:
> Drop ioatdma's use of tx_list from struct dma_async_tx_descriptor in
> preparation for removal of this field.
> 
> Cc: Maciej Sosnowski <maciej.sosnowski@intel.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>