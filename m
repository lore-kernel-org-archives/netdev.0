From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 13:02:16 -0400
Message-ID: <1180544536.4109.100.camel@localhost>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
	 <1180536987.4109.19.camel@localhost>  <465D97F1.9090600@trash.net>
	 <1180541401.4109.72.camel@localhost>  <465DA4E9.5060906@trash.net>
	 <1180542897.4109.81.camel@localhost>  <465DAC73.6070507@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:1886 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757399AbXE3RCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 13:02:19 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1823667wxc
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 10:02:19 -0700 (PDT)
In-Reply-To: <465DAC73.6070507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-30-05 at 18:55 +0200, Patrick McHardy wrote:

> I could do that, but I'm perfectly happy with the qdisc part of SFQ.
> Without the classifier SFQ is of course simply a FQ qdisc, all it
> cares about is serving queues equally.

Sure. You are writting the code - your call.

cheers,
jamal


