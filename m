From: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>
Subject: RE: [patch] wimax/i2400m: remove an unused variable
Date: Fri, 16 Dec 2011 22:09:29 +0000
Message-ID: <3A78FAA0EC814D4B8ECC99B3AB32B332012E56@ORSMSX105.amr.corp.intel.com>
References: <20111216102242.GC4287@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-wimax <linux-wimax@intel.com>,
	"wimax@linuxwimax.org" <wimax@linuxwimax.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40528 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760834Ab1LPWJb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 17:09:31 -0500
In-Reply-To: <20111216102242.GC4287@elgon.mountain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [patch] wimax/i2400m: remove an unused variable
> 
> "result" isn't used.  We ignore errors here because there is not much
> we can do about them.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

This is an ACK or a NAK depending on if you want to keep the reporting
with debug enabled or not. It is not so difficult to add back if needed, 
so I tend to ACK.

Thank you,
