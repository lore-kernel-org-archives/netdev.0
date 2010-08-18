From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [RFC Patch] netxen: remove firmware exports
Date: Wed, 18 Aug 2010 08:19:46 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86E6913F@MNEXMB2.qlogic.org>
References: <20100818095908.6606.56224.sendpatchset@localhost.localdomain>
 <99737F4847ED0A48AECC9F4A1974A4B80F86E69129@MNEXMB2.qlogic.org>
 <4C6BDDCB.9040800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dhananjay Phadke <dhananjay.phadke@qlogic.com>,
	Narender Kumar <narender.kumar@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:36924 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab0HRNTv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 09:19:51 -0400
In-Reply-To: <4C6BDDCB.9040800@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Then we can work with David Woodhouse and make these firmware available in /lib/firmware
>
Actually I was not updated, NX_UNIFIED_ROMIMAGE_NAME (phanfw.bin) is already submitted and its present in linux-firmware.git.

I will get back to you on NX_P2_MN_ROMIMAGE_NAME, NX_P3_CT_ROMIMAGE_NAME and NX_P3_MN_ROMIMAGE_NAME.
Whether this will be submitted ?

-----Original Message-----
From: Cong Wang [mailto:amwang@redhat.com] 
Sent: Wednesday, August 18, 2010 6:49 PM
To: Amit Salecha
Cc: linux-kernel@vger.kernel.org; Dhananjay Phadke; Narender Kumar; netdev@vger.kernel.org; David S. Miller; Ameen Rahman
Subject: Re: [RFC Patch] netxen: remove firmware exports

On 08/18/10 19:04, Amit Salecha wrote:
> If problem is firmware files are not present in /lib/firmware.
> Then we can work with David Woodhouse and make these firmware available in /lib/firmware.
>

Oh, I thought we did this intentionally.
That would be nice then, please go ahead.

Thanks!

-- 
The opposite of love is not hate, it's indifference.
  - Elie Wiesel

