From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 1/5] [VLAN]: Unclassified vlan packet
Date: Tue, 27 May 2008 10:40:33 -0700
Message-ID: <b25c3fa70805271040qb5f5c54tb009b51acc3acd3f@mail.gmail.com>
References: <20080411135714.GA8137@tp64> <483B9EBE.5030703@trash.net>
	 <b25c3fa70805262320h7edb4246wd017261fe7187b88@mail.gmail.com>
	 <483BAA7F.6060408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:59839 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309AbYE0Rkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 13:40:33 -0400
Received: by rv-out-0506.google.com with SMTP id l9so3052755rvb.1
        for <netdev@vger.kernel.org>; Tue, 27 May 2008 10:40:33 -0700 (PDT)
In-Reply-To: <483BAA7F.6060408@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/26 Patrick McHardy <kaber@trash.net>:
>>> BTW, I already have a patch queued to move the VLAN tag from
>>> skb->cb to a seperate skb member to fix the the conflict with
>>> qdiscs (this should also allow to use vlan accel through virtual
>>> network devices later on). So please don't resend, I'll integrate
>>> the patch on top of this change once we find a good spot for
>>> invalidation.
>>>

Was that patch applied to certain tree?
If it was, may I know what tree is it?

>
> Well, we still need to find a good spot for invalidation.
> Suggestions welcome :)
>

huh, also I'll try to find it! :-)

Thanks,
Joonwoo
