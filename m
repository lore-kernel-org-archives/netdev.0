From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 bonding problem, 802.3ad
Date: Thu, 15 Feb 2007 11:26:54 -0800
Message-ID: <20070215112654.40850708@freekitty>
References: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sk-drivers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Holger Eitzenberger <holger@my-eitzenberger.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:58428 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030753AbXBOT1G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 14:27:06 -0500
In-Reply-To: <871wkruu6p.fsf@kruemel.my-eitzenberger.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I used both use_carrier=1 (default) as well as miimon=50 without luck.

use_carrier should work (since device reports carrier transistions).

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
