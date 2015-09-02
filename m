From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/4] net: qdisc: add op to run filters/actions
 before enqueue
Date: Wed, 02 Sep 2015 14:44:48 +0200
Message-ID: <55E6EF40.9060201@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>	<a18f0baba2668f0bbc15a45036713dcaa4bb09b0.1441123709.git.daniel@iogearbox.net> <CAHA+R7O-EAnGL1hhb_WtXXw1-Rj4kiFUqFkDkZe2SKWB-7Otrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	john fastabend <john.fastabend@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <cwang@twopensource.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38884 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315AbbIBMow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 08:44:52 -0400
In-Reply-To: <CAHA+R7O-EAnGL1hhb_WtXXw1-Rj4kiFUqFkDkZe2SKWB-7Otrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2015 08:22 AM, Cong Wang wrote:
> (Why not Cc'ing Jamal for net_sched pathes?)

Sorry, forgot about it, and thanks for the Cc!
