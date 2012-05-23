From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 1/4] stmmac: remove two useless initialisation
Date: Wed, 23 May 2012 09:38:02 +0200
Message-ID: <4FBC93DA.5010206@st.com>
References: <1337754964-21754-1-git-send-email-peppe.cavallaro@st.com> <20120523.024211.816676351593259308.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:54844 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755320Ab2EWHiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 03:38:08 -0400
In-Reply-To: <20120523.024211.816676351593259308.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/23/2012 8:42 AM, David Miller wrote:
> 
> You really need to post your patches properly.
> 
> In particular, you need to indicate, either in an initial "[PATCH 0/N]"
> posting, or in the subject lines of that patch, exactly what tree
> you are targetting.
> 
> And if this is meant for net-next, I told you specifically that net-next
> is not open right now and you need to submit this later when I make
> the announcement here that it is open.
> 
> We are in the middle of the merge window, and therefore you should only
> be submitting bug fixes against the 'net' tree.

Previous ones were for net-next and in fact in the subject I indeed used:

  [net-next X/N] stmmac: ....

After your comment I re-sent them for net.git (pls see my previous email
where I clarified that).

I have always posted all my patches for net-next adding its suffix in
the subject.

For all the patches for net.git I've never added the suffix but I'll do
that.

I agree with you that the suffix should be added and I had understood
(and always used and fixed in my subjectprefix) that these were the
format of the patches in this mailing list

[PATCH] ...        =>>> for net.git
[PATCH net-next]   =>>> for net-next.git

So I'll use starting from now:

[PATCH (net.git)]    =>>> for net.git
[PATCH (net-next)]   =>>> for net-next.git

> It is extremely irritating that, when I go out of my way to make
> announcements here on this list, multiple times, about what kind of
> patches are appropriate and what kinds are not, and yet people still
> do not listen and they still submit any old crap they feel like
> submitting.
> 
> People need to stop this, now.
> 
> Pay attention to the development state, and follow the rules,
> otherwise you'll royally piss me off and I'll ignore your patches
> completely.
> 
> Thanks.
> 
> 
> 
