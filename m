From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Separate the close_list and the unreg_list
Date: Thu, 03 Oct 2013 17:53:36 -0400 (EDT)
Message-ID: <20131003.175336.1790817032247867762.davem@davemloft.net>
References: <CA+HUmGgJYeCj-wod=FsWJuZXQN0Kgbwiv+7iY7r+0BCOdqTDvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	ebiederm@xmission.com
To: fruggeri@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab3JCVxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 17:53:40 -0400
In-Reply-To: <CA+HUmGgJYeCj-wod=FsWJuZXQN0Kgbwiv+7iY7r+0BCOdqTDvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Date: Thu, 3 Oct 2013 14:51:34 -0700

> This patch from Eric may have fallen through the cracks.
> At the time he submitted it I did verify it in some failures I was
> seeing (I have not run extensive tests).

I'd like Eric to explicitly resubmit the patch, as it probably needs
to be respun to apply cleanly anyways.
