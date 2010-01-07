From: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Subject: Re: [PATCH 03/13] stmmac: add the new Header file for stmmac platform
 data
Date: Thu, 07 Jan 2010 10:06:50 -0500
Message-ID: <4B45F88A.2070105@octasic.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com> <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com> <4B45DE02.5010403@octasic.com> <4B45E1D7.80407@st.com> <4B45E5C3.6060205@octasic.com> <4B45E941.1070002@st.com> <4B45EC4B.10602@octasic.com> <4B45EDB8.3070601@st.com> <4B45F10A.3050508@octasic.com> <4B45F7A6.5010008@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.octasic.com ([70.54.254.106]:36380 "EHLO
	MAILEXCH.octasic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753098Ab0AGPGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 10:06:51 -0500
In-Reply-To: <4B45F7A6.5010008@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Giuseppe CAVALLARO wrote:
> I can rework this moving the stmmac platform header from
>  include/linux/stmmac.h
> to
>  drivers/net/stmmac/stmmac_plat.h
>
> On stlinux kernel the include/linux/stm/platform.h header will include
> .../../../drivers/net/stmmac/stmmac_plat.h instead of linux/stmmac.h.
>
> Any other comments?
>   
Nope; I'll let you know if I notice something else.

Thanks!
jh
