From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: implement RFC 5961 4.2
Date: Wed, 18 Jul 2012 00:21:46 +0200
Message-ID: <1342563706.2626.1228.camel@edumazet-glaptop>
References: <1342525290.2626.459.camel@edumazet-glaptop>
	 <CAGK4HS-AMWZ0Ef7G1pvWJ7XADsvxqsiX3tMCe2=oq+_46won6g@mail.gmail.com>
	 <1342560769.2626.1165.camel@edumazet-glaptop>
	 <CAGK4HS8MvP6L5Rvy4wJx2KhdTSSHfP7YPT44e9mrV_vsBZJ9jQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Kiran Kumar Kella <kkiran@broadcom.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:45122 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2GQWVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 18:21:51 -0400
Received: by qcro28 with SMTP id o28so635767qcr.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 15:21:50 -0700 (PDT)
In-Reply-To: <CAGK4HS8MvP6L5Rvy4wJx2KhdTSSHfP7YPT44e9mrV_vsBZJ9jQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-17 at 15:10 -0700, Vijay Subramanian wrote:

> Yes. This is what I had in mind (along with a change to make
> tcp_sequence() return bool). I am not sure if this patch is official
> (or will be picked up by patchwork) but
> for what its worth
> 
> Acked-by: Vijay Subramanian <subramanian.vijay@gmail.com>

Well, I am going to send an official patch with all credits ASAP,

Thanks !
