From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 00/13] NetLabel cleanups for 2.6.20 [GIT]
Date: Sat, 18 Nov 2006 11:10:24 -0500
Message-ID: <200611181110.25281.paul.moore@hp.com>
References: <20061117223842.399078000@hp.com> <XMMS.LNX.4.64.0611172308070.13574@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:32454 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1755137AbWKRQKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Nov 2006 11:10:31 -0500
To: James Morris <jmorris@namei.org>
In-Reply-To: <XMMS.LNX.4.64.0611172308070.13574@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 17 November 2006 11:12 pm, James Morris wrote:
> On Fri, 17 Nov 2006, paul.moore@hp.com wrote:
> > This patchset consists of a lot of small-ish cleanups for NetLabel and in
> > some cases labeled networking in general.  I've tested these patches for
> > the past few days and I haven't seen any regressions so please consider
> > them for the net-2.6.20 git tree.
>
> Thanks, excellent!
>
> There was one minor compilation issue caused by including linux/skbuff.h
> in an SELinux header, which I fixed (see below).

<scratching head>
Huh, sorry about that ... thanks for accepting the patches and making the fix.
</scratching head>

-- 
paul moore
linux security @ hp
