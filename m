From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] pcnet32:  remove unnecessary save/restore register
 accesses.
Date: Wed, 13 Sep 2006 13:25:52 -0400
Message-ID: <45083F20.1000108@pobox.com>
References: <20060913171543.GA12746@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48796 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750822AbWIMRZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 13:25:59 -0400
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20060913171543.GA12746@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied patches 1-5, thanks.

Now, if any problems appear, a 'git bisect' will quickly and easily 
narrow down the problem source.


