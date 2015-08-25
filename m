From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: Re: [PATCH v3 01/10] ss: rooted out ss type declarations for output
 formatters
Date: Tue, 25 Aug 2015 21:13:01 +0200
Message-ID: <55DCBE3D.20206@gmx.net>
References: <1440103221-21854-1-git-send-email-matthias.tafelmeier@gmx.net>	<1440103221-21854-2-git-send-email-matthias.tafelmeier@gmx.net> <20150823100758.74a626d4@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:56773 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042AbbHYTNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 15:13:24 -0400
In-Reply-To: <20150823100758.74a626d4@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2015 07:07 PM, Stephen Hemminger wrote:
> On Thu, 20 Aug 2015 22:40:12 +0200
> Matthias Tafelmeier <matthias.tafelmeier@gmx.net> wrote:
> 
>> The prospected output formatters and ss do share type declarations like
>> slabstat or tcpstat so that the decision has been made to centralize
>> those declarations in ss_types.h.  Potential future declarations shall
>> be placed there. The latter should help amend the extent of ss.c as
>> well.
>>
>> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
>> Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
> 
> I looked at this series, and was going to merge it but the code to do
> json formatting gets really ugly. Please redo it with the json_writer
> code I just added.
> 

Original: "See your point there. I will do that. Thanks."

Had a glitch with my email-client. This time without PGP.
