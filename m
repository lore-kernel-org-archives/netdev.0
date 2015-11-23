From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2 8/9] net: ipmr: rearrange and cleanup setsockopt
Date: Sun, 22 Nov 2015 21:44:30 -0800
Message-ID: <CAHA+R7MO7OSjSTei7pSCZWmJzXNQqS8vPc0Z2fEz_m2vKvkd+Q@mail.gmail.com>
References: <1448117852-4254-1-git-send-email-razor@blackwall.org>
	<1448117852-4254-9-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f180.google.com ([209.85.160.180]:33481 "EHLO
	mail-yk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbbKWFob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 00:44:31 -0500
Received: by ykdv3 with SMTP id v3so226524370ykd.0
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 21:44:30 -0800 (PST)
In-Reply-To: <1448117852-4254-9-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 21, 2015 at 6:57 AM, Nikolay Aleksandrov
<razor@blackwall.org> wrote:
>  net/ipv4/ipmr.c | 191 +++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 107 insertions(+), 84 deletions(-)

Does this really simplify the code? :-/
