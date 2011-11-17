From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next 2/2] team: avoid using variable-length array
Date: Thu, 17 Nov 2011 19:52:52 +0100
Message-ID: <20111117185251.GB3209@minipsycho>
References: <1321539365-1125-2-git-send-email-jpirko@redhat.com>
 <1321540278.2751.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20111117151031.GA3209@minipsycho>
 <20111117.134022.653641656780834689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com, mirqus@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789Ab1KQSw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 13:52:58 -0500
Content-Disposition: inline
In-Reply-To: <20111117.134022.653641656780834689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 17, 2011 at 07:40:22PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Thu, 17 Nov 2011 16:10:32 +0100
>
>> Sure, I'll do this in separate patch.
>
>No, you'll do it in _this_ patch.
>
>Jiri, please stop resisting the incorporation of feedback into
>the patches you post.  You've done this twice in the past 3 days
>and it's really irritating.

Well, the change Eric suggested is unrelated to this patch so it seemed
good to me to do not mangle it together.

Anyway, I'm sorry being source of irritation :( (alhought I have
absolutelly no intention to do so)

Jirka
