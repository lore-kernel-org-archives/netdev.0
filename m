From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 2/2] vxlan: support GPE/NSH
Date: Tue, 1 Mar 2016 19:20:19 +0100
Message-ID: <20160301192019.57b93175@griffin>
References: <1455220626-28244-1-git-send-email-brussell@brocade.com>
	<1455220626-28244-3-git-send-email-brussell@brocade.com>
	<20160215174917.025b066c@griffin>
	<56D578B0.9020605@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Brian Russell <brian.russell@Brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbcCASUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 13:20:24 -0500
In-Reply-To: <56D578B0.9020605@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Mar 2016 11:10:40 +0000, Brian Russell wrote:
> I'd like to add the NSH capability on top of your patchset which I see
> is currently under review. Or did you have plans to roll out NSH soon
> also?

If you have something ready, send it to netdev. I want to add NSH
support but if others write that for me, I won't complain :-)

Adding NSH support to VXLAN-GPE itself is trivial, it's two lines. The
hard part is properly integrating NSH support to tc and openvswitch.

 Jiri
