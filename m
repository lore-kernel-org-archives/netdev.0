From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] doc: packet: add minimal TPACKET_V3 example
 code
Date: Fri, 29 Mar 2013 08:42:17 -0700
Message-ID: <1364571737.5113.25.camel@edumazet-glaptop>
References: <1364571389-26326-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Leblond <eric@regit.org>,
	Victor Julien <victor@inliniac.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:40327 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753859Ab3C2PmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 11:42:20 -0400
Received: by mail-pb0-f44.google.com with SMTP id wz17so303177pbc.31
        for <netdev@vger.kernel.org>; Fri, 29 Mar 2013 08:42:20 -0700 (PDT)
In-Reply-To: <1364571389-26326-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 16:36 +0100, Daniel Borkmann wrote:
> Lost in space for a long time, but it finally came back to us from
> some ancient code tombs. This patch adds a minimal runnable example
> of Linux' packet mmap(2) from Chetan Loke's TPACKET_V3. Special
> thanks to David S. Miller, and also Eric Leblond and Victor Julien!
> 
> Cc: Eric Leblond <eric@regit.org>
> Cc: Victor Julien <victor@inliniac.net>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  Documentation/networking/packet_mmap.txt | 327 +++++++++++++++++++++++++++++++
>  1 file changed, 327 insertions(+)

tools/testing/selftests/net  seems a better place to get another
program ?
