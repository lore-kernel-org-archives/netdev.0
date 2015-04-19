From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] ip: Add color output option
Date: Sun, 19 Apr 2015 10:22:50 +0200
Message-ID: <553365DA.7070807@iogearbox.net>
References: <20150417130202.GA29596@iki.fi> <20150417164402.GA7041@Alexeis-MBP.westell.com> <5531425E.1020206@iogearbox.net> <20150418102258.GA7005@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev@vger.kernel.org, aleksi.aalto@iki.fi
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40445 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbbDSIWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 04:22:52 -0400
In-Reply-To: <20150418102258.GA7005@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2015 12:22 PM, Mathias Nyman wrote:
...
> I don't understand what you mean by "-c is neither taken in ip nor in
> tc or ss".

That just means we could in future consider to consistently add support
for -c flag in those tools, too.
