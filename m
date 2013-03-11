From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next.git 6/9] stmmac: add missing supported filters to get_ts_info
Date: Mon, 11 Mar 2013 07:39:53 +0100
Message-ID: <513D7C39.2030307@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com> <1362653419-1047-7-git-send-email-peppe.cavallaro@st.com> <20130310123632.GC6407@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bh74.an@samsung.com,
	ayagond@vayavyalabs.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-eu.st.com ([164.129.1.35]:47781 "EHLO
	beta.dmz-eu.st.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3CKGjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 02:39:55 -0400
In-Reply-To: <20130310123632.GC6407@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/10/2013 1:36 PM, Richard Cochran wrote:
> On Thu, Mar 07, 2013 at 11:50:16AM +0100, Giuseppe CAVALLARO wrote:
>> This patch updates the filters for ethtool's get_ts_info to return support for
>> all filters which can be supported after having added the PTP support.
>
> This code should ideally appear in the same patch where the filtering
> support first appears.

Ok, I'll add it inside the patch that adds the support.

peppe

>
> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
