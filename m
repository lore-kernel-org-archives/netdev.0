From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] net, sched: add skb_at_tc_ingress helper
Date: Thu, 7 Jan 2016 10:12:13 -0800
Message-ID: <20160107181212.GA3257@ast-mbp.thefacebook.com>
References: <cover.1452176592.git.daniel@iogearbox.net>
 <9217fc7175fd37df60c7fdac811a35dc957d9326.1452176592.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36378 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbcAGSMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 13:12:15 -0500
Received: by mail-pa0-f44.google.com with SMTP id yy13so171824037pab.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 10:12:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <9217fc7175fd37df60c7fdac811a35dc957d9326.1452176592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 03:50:22PM +0100, Daniel Borkmann wrote:
> Add a skb_at_tc_ingress() as this will be needed elsewhere as well and
> can hide the ugly ifdef.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@kernel.org>
