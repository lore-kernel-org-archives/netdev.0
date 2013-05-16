From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 5/5] net: davinci_mdio: trivial cleanup
Date: Thu, 16 May 2013 22:58:03 +0400
Message-ID: <51952C3B.80202@cogentembedded.com>
References: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com> <1368689438-23889-6-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	Mugunthan V N <mugunthanvnm@ti.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Lad Prabhakar <prabhakar.csengg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:57226 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab3EPS6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 14:58:03 -0400
Received: by mail-la0-f46.google.com with SMTP id fk20so3401298lab.33
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 11:58:01 -0700 (PDT)
In-Reply-To: <1368689438-23889-6-git-send-email-prabhakar.csengg@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-05-2013 11:30, Lad Prabhakar wrote:

> From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

> remove unwanted header inclusion and sort the alphabetically

    s/the/them/.

> also guard the davinci_mdio_of_mtable table and davinci_mdio_probe_dt()
> with CONFIG_OF.

    Saying "also" in the changelog is often a good sign there should be 
one more patch -- as in this case.

> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

WBR, Sergei
