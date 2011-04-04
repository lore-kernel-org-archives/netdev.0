From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH 6/8] benet: convert to set_phys_id
Date: Mon, 4 Apr 2011 15:32:57 -0700
Message-ID: <bd9b17b0-f82b-4689-a627-4050869d8074@exht2.ad.emulex.com>
References: <20110404210634.840793593@linuxplumber.net>,<20110404210805.802043416@linuxplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <shemminger@vyatta.com>, <davem@davemloft.net>,
	<bhutchings@solarflare.com>, <Sathya.Perla@Emulex.Com>,
	<subbu.seetharaman@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:33457 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755555Ab1DDWdW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 18:33:22 -0400
In-Reply-To: <20110404210805.802043416@linuxplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

_______________________________________
From: Stephen Hemminger [shemminger@vyatta.com]
Sent: Monday, April 04, 2011 4:06 PM
To: David S. Miller; Ben Hutchings; Perla, Sathya; Seetharaman, Subramanian; Khaparde, Ajit
Cc: netdev@vger.kernel.org
Subject: [PATCH 6/8] benet: convert to set_phys_id

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


Thanks Stephen. You finished the work, while I was in the middle of the same.

I have picked this patch for testing. I guess the ethtool patches will be re-spun.
So I will probably wait for that before I send an update.

-Ajit