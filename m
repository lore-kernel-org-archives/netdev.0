From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH net-next 1/3] netpoll: prepare for ipv6
Date: Wed, 02 Jan 2013 17:44:15 +0800
Message-ID: <1357119855.2357.0.camel@cr0>
References: <1357027288-28675-1-git-send-email-amwang@redhat.com>
	 <20130101.230712.118939414426489213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41667 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422Ab3ABJoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2013 04:44:21 -0500
In-Reply-To: <20130101.230712.118939414426489213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-01 at 23:07 -0800, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Tue,  1 Jan 2013 16:01:26 +0800
> 
> > +	int ipv6;
> 
> Use 'bool' please.

OK. I will update this.
