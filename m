From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 0/9] stmmac: update to March_2013 (adding PTP &
 RGMII/SGMII)
Date: Fri, 8 Mar 2013 07:04:46 +0100
Message-ID: <20130308060445.GA2382@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	ayagond@vayavyalabs.com
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:63349 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932158Ab3CHGEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 01:04:52 -0500
Received: by mail-wi0-f181.google.com with SMTP id hm6so714179wib.14
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 22:04:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 11:50:10AM +0100, Giuseppe CAVALLARO wrote:

> Rayagond Kokatanur (4):
>   stmmac: add tx_skbuff_dma to save descriptors used by PTP
>   stmmac: add IEEE 1588-2002 PTP support
>   stmmac: add the support for PTP hw clock driver
>   stmmac: add IEEE 1588-2008 PTP V2 support

In the future, for PTP clock and time stamping patches, I would
appreciate being put on CC.

Thanks,
Richard
