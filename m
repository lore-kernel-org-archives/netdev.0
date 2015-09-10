From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 1/5] stmmac: replace all pr_xxx by their netdev_xxx
 counterpart
Date: Thu, 10 Sep 2015 08:44:54 -0700
Message-ID: <1441899894.17219.160.camel@perches.com>
References: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
	 <1441888653-30535-2-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0150.hostedemail.com ([216.40.44.150]:52246 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752659AbbIJPo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 11:44:57 -0400
In-Reply-To: <1441888653-30535-2-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-09-10 at 14:37 +0200, LABBE Corentin wrote:
> So this patch replace all pr_xxx by their dev_xxx counterpart.

Minor mismatch between subject and commit message.
Maybe not worth resending.

Thanks
