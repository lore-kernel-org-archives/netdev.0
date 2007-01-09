From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] INET: fix incorrect "inet_sock->is_icsk" assignment
Date: Tue, 9 Jan 2007 09:26:46 -0500
Message-ID: <200701090926.47206.paul.moore@hp.com>
References: <20070108132548.GA2324@ff.dom.local> <200701080947.29270.paul.moore@hp.com> <20070109084322.GB1703@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim03.cce.hp.com ([161.114.21.24]:20350 "EHLO
	ccerelrim03.cce.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbXAIOqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 09:46:00 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20070109084322.GB1703@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 January 2007 3:43 am, Jarek Poplawski wrote:
> ... But if you consider this code will probably become classical
> and will be read, quoted and teached next 1000 years, then the style
> could matter... 

This from the guy who believes "Justin Timberlake rocks!" ;)

All right, you convinced me, I'll send out a patch to the patch later today.

-- 
paul moore
linux security @ hp
