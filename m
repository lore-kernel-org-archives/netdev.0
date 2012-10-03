From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 4/5] ucc_geth: Increase RX ring buffer from 32 to 64
Date: Wed, 3 Oct 2012 22:13:36 +0200
Message-ID: <OFA3DBC011.F1E51FFB-ONC1257A8C.006E2EE6-C1257A8C.006F1C0A@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se>	<1347987385-19071-4-git-send-email-Joakim.Tjernlund@transmode.se>
	<OF4BE93D25.4AE817F3-ONC1257A8C.004909F7-C1257A8C.00490EAC@transmode.se> <20121003.153855.325707079634367524.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:52849 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753098Ab2JCUNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 16:13:40 -0400
In-Reply-To: <20121003.153855.325707079634367524.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 2012/10/03 21:38:55:
>
> From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> Date: Wed, 3 Oct 2012 15:17:58 +0200
>
> > Ping? Got no comments and I can see it in net or net-next trees either.
>
> No patch will be applied to the tree when one of the indiviual patches
> get feedback and request changes from you.
>
> When an individual patch must be redone, you must resend the entire
> series not just the individual patch which changed.

oh, I see what I did wrong. I sent them as series which may have internal dependencies.
However, each patch can be applied on its own.

>
> You also never need to ask the kind of question you are asking here,
> you simply need to look into patch work to see what the state of
> your patches is:
>
> I maintain this state exactly so people don't need to waste precious
> developer time asking "what is the state of my patch" like you are
> making me do right here.
>
> See:
>
> http://patchwork.ozlabs.org/project/netdev/list/?state=*&q=ucc_geth

Ahh, better bookmark this page for future use.

>
> And as you can see this entire series is marked as either "RFC"
> or "Changes Requested"

Yes, I see that now.
I guess I should resend each patch separately then?
(Possibly wait until I have figured out the lockless TX stuff)

>
> Even worse, you did this for not one but several of the patches you
> posted.

Sorry about that.

 Jocke
