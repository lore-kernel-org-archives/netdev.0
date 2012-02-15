From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 0/4 (net.git)] stmmac update Feb_2012
Date: Wed, 15 Feb 2012 10:55:13 +0100
Message-ID: <4F3B8101.1090509@st.com>
References: <1329203508-19612-1-git-send-email-peppe.cavallaro@st.com> <20120214.141620.1418537030681644675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:34390 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751227Ab2BOJzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 04:55:22 -0500
In-Reply-To: <20120214.141620.1418537030681644675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/14/2012 8:16 PM, David Miller wrote:
> From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
> Date: Tue, 14 Feb 2012 08:11:44 +0100
> 
>> This updates the stmmac adding some patches already reviewed in this
>> mailing list by D. Miller.  I've rebased these patches against this
>> recent patch: [PATCH] [trivial] stmicro: Fix typo in stmmac_pci.c
>> and stmmac_platform.c applied by Maintainer (to avoid conflicts in
>> the plt and pci files).
> 
> You're telling me in the subject line you want these patches applied
> to net.git but they don't actually apply cleanly to that tree.
> 
> I can't tell you how insanely irritating this kind of thing is, it's
> where most of my time gets wasted.

Sorry for that. I actually wanted to avoid just this.

Erroneously, I prepared these patches against the net.git plus the patch
named : [PATCH] [trivial] stmicro: Fix typo in stmmac_pci.c
I believed you had locally applied it (14/Feb/2012).

I am reworking these patches against the net.git at once promising you
that they will apply perfectly!

Regards
Peppe

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
