From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [RFC 37/72] fsl_*/gianfar*/ucc_*: Move the Freescale drivers
Date: Wed, 29 Jun 2011 15:39:51 +0000
Message-ID: <BANLkTikrLzkXCjzBBOwHUQZEdnzTSZv9bA@mail.gmail.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-38-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sandeep Gopalpet <sandeep.kumar@freescale.com>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	Gridish Shlomi-RM96313 <RM96313@freescale.com>,
	Li Yang-R58472 <r58472@freescale.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:8933 "EHLO
	VA3EHSOBE010.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842Ab1F2P4N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 11:56:13 -0400
In-Reply-To: <1309010363-22750-38-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Content-ID: <77D58844782949459C4E0F502C792A50@freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2011 at 8:58 AM, Jeff Kirsher
<jeffrey.t.kirsher@intel.com> wrote:
> Move the Freescale driver into drivers/net/ethernet/freescale/ and
> make the necessary Kconfig and Makefile changes.

I don't have an actual objection to this, but I just don't understand
why it's necessary.  Is this a new trend for drivers/net, to have all
drivers grouped by manufacturer?  Or is there something special about
Freescale?

-- 
Timur Tabi
Linux kernel developer at Freescale
