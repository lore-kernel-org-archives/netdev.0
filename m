From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next.git 6/9] stmmac: add missing supported filters to
 get_ts_info
Date: Sun, 10 Mar 2013 13:36:32 +0100
Message-ID: <20130310123632.GC6407@netboy.at.omicron.at>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
 <1362653419-1047-7-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	ayagond@vayavyalabs.com
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:40470 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751074Ab3CJMgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 08:36:42 -0400
Received: by mail-ee0-f44.google.com with SMTP id l10so1797305eei.31
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 05:36:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1362653419-1047-7-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 11:50:16AM +0100, Giuseppe CAVALLARO wrote:
> This patch updates the filters for ethtool's get_ts_info to return support for
> all filters which can be supported after having added the PTP support.

This code should ideally appear in the same patch where the filtering
support first appears.

Thanks,
Richard
