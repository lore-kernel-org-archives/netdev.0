From: Daniel Wagner <wagi@monom.org>
Subject: Re: CONNMARK getsockopt/setsockopt functionality
Date: Fri, 23 Jul 2010 16:50:51 +0200
Message-ID: <20100723145051.GA13807@pc0043.bmw-carit.intra>
References: <20100721072006.GA17965@pc0043.bmw-carit.intra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from toronto053.server4you.de ([62.75.220.53]:46323 "EHLO
	toronto053.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab0GWOu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 10:50:56 -0400
Received: from localhost (mail.bmw-carit.de [62.245.222.98])
	(Authenticated sender: wagi)
	by toronto053.server4you.de (Postfix) with ESMTPSA id 0190454198
	for <netdev@vger.kernel.org>; Fri, 23 Jul 2010 14:50:50 +0000 (UTC)
Content-Disposition: inline
In-Reply-To: <20100721072006.GA17965@pc0043.bmw-carit.intra>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> There used to be a way to mark packets in userspace by invoking the
> setsocketopt with SO_CONNMARK as it was proposed by Krisztian [1].
> This code was superseeded by Jan's work [2]. Now I wonder how I get
> the same result out of the new code. Something with conditions? 

Silly me, the above statement is completely wrong. I was looking for
SO_MARK which is obviously still there. Sorry for the noise.

thanks,
daniel
