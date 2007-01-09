From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] s390: qeth driver fixes
Date: Tue, 09 Jan 2007 08:45:44 -0500
Message-ID: <45A39C88.5070606@pobox.com>
References: <20070108162934.GA21639@de.ibm.com> <45A342EB.2020200@pobox.com> <20070109133922.GA21804@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34520 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399AbXAINpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 08:45:49 -0500
To: Frank Pavlic <fpavlic@de.ibm.com>
In-Reply-To: <20070109133922.GA21804@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frank Pavlic wrote:
> Sorry for the trouble and also thank you very much
> for having done the extra work. I made the patches
> using git-format-patch so seems that I have to review
> them more carefully or I still haven't understand to use
> git-format-patch properly. 
> In any case I will read the documents you mentioned 
> once again to keep such points in mind...

If you are using git, maybe its as simple as checking in each patch with 
a unique first-line (== one-line summary)?

Also, if you so choose, you are welcome to submit changes directly via 
git to me, just like Martin Schwidefsky does with the main S/390 changes.

	Jeff



