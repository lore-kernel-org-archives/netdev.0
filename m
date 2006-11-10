From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Subject: Re: [PATCH] dccp: remove module exit functions
Date: Fri, 10 Nov 2006 16:32:16 -0200
Message-ID: <39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
References: <XMMS.LNX.4.64.0611100345300.10983@d.namei>
	 <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
	 <XMMS.LNX.4.64.0611101122520.15046@d.namei>
	 <XMMS.LNX.4.64.0611101126150.15046@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "dccp (vger)" <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:6698 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1161871AbWKJScR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 13:32:17 -0500
Received: by wx-out-0506.google.com with SMTP id s7so138689wxc
        for <netdev@vger.kernel.org>; Fri, 10 Nov 2006 10:32:16 -0800 (PST)
To: "James Morris" <jmorris@namei.org>
In-Reply-To: <XMMS.LNX.4.64.0611101126150.15046@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/10/06, James Morris <jmorris@namei.org> wrote:
> On Fri, 10 Nov 2006, James Morris wrote:
>
> > I wonder if this facility can be integrated more generally into the kernel
> > protocol which people are developing.
>
> Ugh, editor screwup.  That was meant to be
>
> I wonder if this facility can be integrated more generally into the kernel
> as a kernel hacking option, as this is not the only protocol which people
> are developing.
>

See:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff

This one requires a bit more thinking, so I'm postponing it for now to
get the simple bits in Gerrit's patch queue cherrypicked and sent for
Dave.

- Arnaldo
