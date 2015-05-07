From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 08/10] e1000: Replace e1000_free_frag with skb_free_frag
Date: Thu, 7 May 2015 01:46:29 -0700
Message-ID: <CAL3LdT47e8FXqXW_DeCygid0DgJjQ5Xss4fvyfn2vOXP9WPcew@mail.gmail.com>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
	<20150507041220.1873.80925.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35021 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbbEGIq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 04:46:29 -0400
Received: by obcux3 with SMTP id ux3so26402134obc.2
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 01:46:29 -0700 (PDT)
In-Reply-To: <20150507041220.1873.80925.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2015 at 9:12 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c |   19 +++++++------------
>  1 file changed, 7 insertions(+), 12 deletions(-)

Was my ACK of the first patch not good enough? :-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
