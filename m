From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Don't init ptp again when resume from
 suspend/hibernation
Date: Thu, 18 Dec 2014 15:36:50 -0500 (EST)
Message-ID: <20141218.153650.2242996610693466579.davem@davemloft.net>
References: <1418884794-15483-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, vbridgers2013@gmail.com,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: chenhc@lemote.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbaLRUgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 15:36:53 -0500
In-Reply-To: <1418884794-15483-1-git-send-email-chenhc@lemote.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Two problems:

1) This post did not reach netdev and therefore did not make it into
   patchwork for tracking.  You need to correct this.

2) Do not CC: stable on networking changes, instead ask me explicitly
   to queue them up for -stable submission and to which trees.
