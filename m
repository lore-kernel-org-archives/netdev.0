From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next-2.6 PATCH v7 2/2] bridge: netlink dump interface at
 par with brctl
Date: Thu, 10 Jul 2014 06:08:00 -0700
Message-ID: <20140710060800.53bf7718@samsung-9>
References: <1404990119-16968-1-git-send-email-jhs@emojatatu.com>
	<1404990119-16968-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:60277 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630AbaGJNIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 09:08:07 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so10795333pdi.18
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 06:08:06 -0700 (PDT)
In-Reply-To: <1404990119-16968-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jul 2014 07:01:59 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> +				/* !f->dst is a speacial case for bridge
> +				 * It means the MAC belongs to the bridge
> +				 * Therefore need a little more filtering
> +				 * we only want to dump the 

Spelling error
