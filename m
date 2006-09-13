From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for '8139cp-20060912-00' branch
Date: Tue, 12 Sep 2006 22:03:01 -0400
Message-ID: <450766D5.1070802@garzik.org>
References: <20060912192039.GA4482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44165 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751492AbWIMCDE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 22:03:04 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060912192039.GA4482@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from tag '8139cp-20060912-00' in repository
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git
> 
> to get the change below:
> 
> (patch applies to jeff#upstream-linus)

Pulled, but there are some git problems to address...

* Never use 'upstream-linus' branch.

* Base off of vanilla Linus linux-2.6.git, unless you are submitting on 
top of changes that are in netdev#upstream or netdev#upstream-fixes.

* For some reason, when I pulled, it fetched over 17,000 objects!

	Jeff



