From: "=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?=" <bro.devel@gmail.com>
Subject: Re: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Fri, 18 Mar 2016 15:25:03 +0100
Message-ID: <56EC0FBF.7040609@gmail.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eKu_0ReSDLYdyajxMyX2MaN=wDLHvq=u_tyNnMRS31sw@mail.gmail.com>
 <56E5F54F.3050507@gmail.com>
 <CAK6E8=e5tVX3cfwvaXxN7LEq6XggeT5Y7T0j4KcKRsA1b-77mQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?UTF-8?Q?P=c3=a5l_Halvorsen?= <paalh@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Yuchung Cheng <ycheng@google.com>,
	=?UTF-8?Q?Bendik_R=c3=b8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:35230 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933725AbcCROZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 10:25:13 -0400
Received: by mail-lb0-f196.google.com with SMTP id wn5so6916147lbb.2
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 07:25:13 -0700 (PDT)
In-Reply-To: <CAK6E8=e5tVX3cfwvaXxN7LEq6XggeT5Y7T0j4KcKRsA1b-77mQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/03/16 22:59, Yuchung Cheng wrote:
> OK that makes sense.
>
> I left some detailed comments on the actual patches. I would encourage
> to submit an IETF draft to gather feedback from tcpm b/c the feature
> seems portable.

Thank you for the suggestion, we appreciate the confidence. We have
had in mind to eventually pursue a standardization process, but have
been unsure about how a mechanism that actively introduces redundancy
would be received by the IETF. It may now be the right time to propose
the RDB mechanism, and we will aim to present an IEFT draft in the
near future.


Bendik
