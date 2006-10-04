From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] prism54: wpa support for fullmac cards
Date: Wed, 4 Oct 2006 12:38:49 +0200
Message-ID: <20061004123849.060a1842@griffin.suse.cz>
References: <200610031457.33215.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:58001 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030800AbWJDKjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 06:39:00 -0400
To: chunkeey@web.de
In-Reply-To: <200610031457.33215.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 3 Oct 2006 14:57:33 +0200, chunkeey@web.de wrote:
> This patch (prism54-en-wpa3.patch) brings WPA/WPA2(RSN) with 
> TKIP-Cipher to everyone with a FULLMAC Prism GT/Indigo/Duette card.
> I removed all the parts(e.g.: Hostapd Support) which are not relevant for 
> wpa_supplicant (client/managed mode).

Are you proposing a patch that removes AP support from the driver or did
I understand it wrong?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
