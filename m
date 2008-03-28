From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] GENETLINK: Global lock refined to family granularity
Date: Thu, 27 Mar 2008 20:29:58 -0700 (PDT)
Message-ID: <20080327.202958.17409612.davem@davemloft.net>
References: <47EB8D8D.8020506@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: richard.musil@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751800AbYC1D36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 23:29:58 -0400
In-Reply-To: <47EB8D8D.8020506@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard MUSIL <richard.musil@st.com>
Date: Thu, 27 Mar 2008 13:05:33 +0100

> This patch is a revive of the patch I posted half a year ago. In
> that time Thomas Graf (who was acting as maintainer of genetlink
> module) accepted the idea, but suggested to do it using RCU
> lists. Since I did not have and experience with RCU lists, we
> agreed, he will implement it himself.
> 
> Since that time, he neither did it, nor replied to my recent emails
> and I guess he is no longer active.

He is active, just very busy this past few months.

Please, be patient.

