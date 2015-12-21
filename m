From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] ixgbevf: Fix handling of napi budget
 when	multiple queues are enabled per vector
Date: Mon, 21 Dec 2015 21:29:05 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180CFA411@ORSMSX108.amr.corp.intel.com>
References: <1446225390-19140-1-git-send-email-william@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: William Dauchy <william@gandi.net>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16349 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbbLUV3H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 16:29:07 -0500
In-Reply-To: <1446225390-19140-1-git-send-email-william@gandi.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of William Dauchy
> Sent: Friday, October 30, 2015 10:16 AM
> To: davem@davemloft.net
> Cc: William Dauchy; netdev@vger.kernel.org; aduyck@mirantis.com; intel-
> wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [PATCH] ixgbevf: Fix handling of napi budget when
> multiple queues are enabled per vector
> 
> This is the same patch as for ixgbe but applied differently according to busy
> polling.
> see commit "ixgbe: Fix handling of napi budget when multiple queues are
> enabled per vector"
> 
> Signed-off-by: William Dauchy <william@gandi.net>

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
