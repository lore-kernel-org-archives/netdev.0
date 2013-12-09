From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v2] 6lowpan: Moving generic compression code
 into 6lowpan_iphc.c
Date: Mon, 9 Dec 2013 09:18:33 +0100
Message-ID: <20131209081833.GB2062@omega>
References: <1386576963-21764-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:39012 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760761Ab3LIISg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 03:18:36 -0500
Received: by mail-wg0-f53.google.com with SMTP id k14so3087569wgh.32
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 00:18:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1386576963-21764-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

thanks for working on this! Now my acked-by is correct, sry. Didn't
catch the debug output at first time.

On Mon, Dec 09, 2013 at 10:16:03AM +0200, Jukka Rissanen wrote:
> Because the IEEE 802154 and Bluetooth share the IP header compression
> and uncompression code, the common code is moved to 6lowpan_iphc.c
> file.
> 
> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> ---

Acked-by: Alexander Aring <alex.aring@gmail.com>
