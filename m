From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] Two cls_bpf fixes
Date: Mon, 26 Jan 2015 15:50:42 -0800 (PST)
Message-ID: <20150126.155042.416219712631506457.davem@davemloft.net>
References: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbbA0AJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:09:01 -0500
In-Reply-To: <1421919662-21066-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 22 Jan 2015 10:41:00 +0100

> Found them while doing a review on act_bpf and going over the
> cls_bpf code again. Will also address the first issue in act_bpf
> as it needs to be fixed there, too.

Series applied, thanks.
