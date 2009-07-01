From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCHv3 1/2] net: adding memory barrier to the poll and receive
 callbacks
Date: Wed, 1 Jul 2009 08:14:47 -0700 (PDT)
Message-ID: <alpine.DEB.1.10.0907010812110.10303@makko.or.mcafeemobile.com>
References: <20090630125240.GB4406@jolsa.lab.eng.brq.redhat.com> <20090630125425.GC4406@jolsa.lab.eng.brq.redhat.com> <alpine.DEB.1.10.0906301210210.3968@makko.or.mcafeemobile.com> <20090701065724.GA2852@jolsa.lab.eng.brq.redhat.com>
 <alpine.DEB.1.10.0907010002010.8492@makko.or.mcafeemobile.com> <20090701073001.GA4769@jolsa.lab.eng.brq.redhat.com> <20090701080946.GB4769@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, oleg@redhat.com,
	eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:43586 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbZGAPPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 11:15:23 -0400
Received: from makko.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.26 ESMTP Server]
	id <S2F5144> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Wed, 1 Jul 2009 11:14:32 -0400
In-Reply-To: <20090701080946.GB4769@jolsa.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Jul 2009, Jiri Olsa wrote:

> ok, how about this

Looks good. maybe you can remove things like "The fix is generic for other 
protocols as well", that are more fot for the email body patch 
description.


- Davide


