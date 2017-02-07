From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] bpf: expose netns inode to bpf programs
Date: Mon, 6 Feb 2017 17:43:51 -0800
Message-ID: <20170207014349.GB83671@ast-mbp.thefacebook.com>
References: <87r33fevva.fsf@xmission.com>
 <CALCETrWDxVHc4_hpjLQRj-XbvGX0+tbGZ8o388-xn6rNcQTySQ@mail.gmail.com>
 <20170203230830.GC26227@ast-mbp.thefacebook.com>
 <CALCETrUb1Rf-BdSTHdKSgwnftHjpmcDt1HX1KX-cpN=N7ev+eg@mail.gmail.com>
 <20170205031045.GC73775@ast-mbp.thefacebook.com>
 <CALCETrUhE_Ga4PeobPFvhtLPVGKskTUaXe9H0v=kBXe4ii7dLw@mail.gmail.com>
 <20170205034839.GG73775@ast-mbp.thefacebook.com>
 <CALCETrXgBrWmWFghWxtV92RDvqYBHsT-L37ujvexyA6v+3M8sQ@mail.gmail.com>
 <20170205043716.GI73775@ast-mbp.thefacebook.com>
 <CALCETrUvnfRuN8=X9d7Hi5mF95n7XS6_muh7GTuKiLO_RtGbxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Tejun Heo <tj@kernel.org>, Thomas Graf <tgraf@suug.ch>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36238 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752616AbdBGBoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 20:44:01 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so10531800pgf.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 17:44:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrUvnfRuN8=X9d7Hi5mF95n7XS6_muh7GTuKiLO_RtGbxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 09:05:29PM -0800, Andy Lutomirski wrote:
> 
> I'm not saying that at all.  I'm saying that this use case sounds
> valid, but maybe it could be solved differently.  Here are some ideas:

Great. Combining multiple threads. Replied in bpf_sk_netns_id thread.
