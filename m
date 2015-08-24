From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Tue, 25 Aug 2015 01:33:46 +0200
Message-ID: <20150824233346.GA30812@electric-eye.fr.zoreil.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440151756-18165-1-git-send-email-vinschen@redhat.com>
 <20150821193926.GA16437@electric-eye.fr.zoreil.com>
 <20150821220756.GI19683@calimero.vinschen.de>
 <20150821235940.GA20313@electric-eye.fr.zoreil.com>
 <20150822083916.GA17408@calimero.vinschen.de>
 <20150822112334.GB24519@electric-eye.fr.zoreil.com>
 <20150824073348.GL19683@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>,
	David Miller <davem@davemloft.net>,
	nic_swsd <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59602 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbHXXeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 19:34:23 -0400
Content-Disposition: inline
In-Reply-To: <20150824073348.GL19683@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
> On Aug 22 13:23, Francois Romieu wrote:
[...]
> > Sorry, my english was really bad:
> > 
> > the code should propagate failure when rtl8169_reset_counters and
> > rtl8169_update_counters *simultaneously* fail.
> 
> Uhm... sorry, but that still doesn't answer the question.  As you can
> see in my patch, the initalization at open time is already encapsulated
> in a function rtl8169_init_counter_offsets. 

I have read your patch, I have already answered the question and I have
already said that it wasn't a showstopper.

-- 
Ueimor
