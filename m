From: Jean-Hugues Deschenes <jean-hugues.deschenes@octasic.com>
Subject: Re: stmmac latest patches  (Dec09)
Date: Thu, 10 Dec 2009 10:16:34 -0500
Message-ID: <4B2110D2.9050801@octasic.com>
References: <1259836805-7512-1-git-send-email-peppe.cavallaro@st.com> <4B179616.2010907@st.com> <4B20F8FE.90804@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.octasic.com ([70.54.254.106]:6328 "EHLO
	MAILEXCH.octasic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760869AbZLJPbk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 10:31:40 -0500
In-Reply-To: <4B20F8FE.90804@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Giuseppe CAVALLARO wrote:
> - - [PATCH 1/4] stmmac: thinking about a generic driver for Synopsys
> Controllers.
>   
Looks good to me. This way, the driver architecture will more closely 
follow the Synopsys IP architecture.
> - - [PATCH 2/4] stmmac: add the new Header file for stmmac platform data
> - - [PATCH 3/4] stmmac: use MII_BUS_ID_SIZE instead of  BUS_ID_SIZE
> - - [PATCH 4/4] stmmac: convert unicast addr list to list_head
>   
These 3 basically fix build errors with the newer kernels. great.

jh
