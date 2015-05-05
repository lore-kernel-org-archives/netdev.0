From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH -next 5/5] skbuff: remove tc_verd member
Date: Tue, 05 May 2015 13:09:10 +0200
Message-ID: <5548A4D6.9000400@iogearbox.net>
References: <1430765318-13788-1-git-send-email-fw@strlen.de> <1430765318-13788-6-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60808 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757853AbbEELJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:09:11 -0400
In-Reply-To: <1430765318-13788-6-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2015 08:48 PM, Florian Westphal wrote:
> not used anymore; replaced with tc_nocls and tc_{at,from}_ingress flags.
>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Nice cleanup!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
