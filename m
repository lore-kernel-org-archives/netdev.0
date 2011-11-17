From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] net: add the nwhwconfig support
Date: Thu, 17 Nov 2011 03:06:25 -0500 (EST)
Message-ID: <20111117.030625.229541498275597867.davem@davemloft.net>
References: <1321516900-616-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mamoroso@micron.com, shiraz.hashim@st.com,
	armando.visconti@st.com, stuart.menefy@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677Ab1KQIGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 03:06:34 -0500
In-Reply-To: <1321516900-616-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 17 Nov 2011 09:01:40 +0100

> Network drivers support hardware level configuration via utilities such as
> ifconfig, ethtool and mii-tool. However sometimes these settings need to be
> adjusted before a file system is available (typically if the root file system
> uses NFS).

No way, use an initial ramdisk.
