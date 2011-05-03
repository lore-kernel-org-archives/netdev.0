From: viresh kumar <viresh.kumar@st.com>
Subject: Re: [PATCH] linux/stmmac.h: include <linux/platform_device.h> to
 remove compilation warning.
Date: Tue, 3 May 2011 09:15:34 +0530
Message-ID: <4DBF7A5E.5030708@st.com>
References: <2239eca1d15014be7b6d94f883f9492dc1fbc60a.1304317552.git.viresh.kumar@st.com> <4DBEA791.4010900@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shiraz HASHIM <shiraz.hashim@st.com>,
	Armando VISCONTI <armando.visconti@st.com>,
	Deepak SIKRI <deepak.sikri@st.com>,
	"viresh.linux@gmail.com" <viresh.linux@gmail.com>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:50134 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751268Ab1ECDpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 23:45:43 -0400
In-Reply-To: <4DBEA791.4010900@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2011 06:16 PM, Giuseppe CAVALLARO wrote:
> We could also remove this inclusion (see commit
> 1f0f63885658889b3bcb8a08fbcb9532f8e536c9) from
> drivers/net/stmmac/stmmac.h and keep it in linux/stmmac.h as you suggested.

Yes, i will do that and resend.

-- 
viresh
