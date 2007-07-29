From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 0/7] SFQ: backport some features from ESFQ
Date: Sun, 29 Jul 2007 00:17:15 -0700
Message-ID: <46AC3EFB.6040504@fatooh.org>
References: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:46605 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759524AbXG2HRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jul 2007 03:17:12 -0400
Received: from localhost (localhost [127.0.0.1])
	by hot.fatooh.org (Postfix) with ESMTP id EB2A917C1AD
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 02:17:12 -0500 (CDT)
Received: from hot.fatooh.org ([127.0.0.1])
	by localhost (hot.fatooh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id nYe4PyeA+-e3 for <netdev@vger.kernel.org>;
	Sun, 29 Jul 2007 02:17:12 -0500 (CDT)
Received: from [10.1.0.0] (c-76-102-59-34.hsd1.ca.comcast.net [76.102.59.34])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by hot.fatooh.org (Postfix) with ESMTP id AC7E317C05B
	for <netdev@vger.kernel.org>; Sun, 29 Jul 2007 02:17:12 -0500 (CDT)
In-Reply-To: <11856929352537-git-send-email-bugfood-ml@fatooh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corey Hickey wrote:
> Hello,
> 
> This set of patches adds some of ESFQ's modifications to the original 
> SFQ. Thus far, I have received support for this approach rather than for 
> trying to get ESFQ included as a separate qdisc.

Crud; I wasn't expecting git-send-email to thread the messages that way. 
I guess I should have used --no-chain-reply-to. If I ought re-send this 
series with that option, somebody please say the word and I'll do so.

-Corey
