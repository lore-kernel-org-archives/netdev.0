From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Date: Tue, 13 Oct 2009 15:42:32 -0300
Message-ID: <20091013184232.GF21809@ghostprotocols.net>
References: <4AD4B677.4000308@embedded.ufcg.edu.br> <4AD4C19E.5060608@gmail.com> <cb00fa210910131112w5e4cc3a6gd46b480efdb55262@mail.gmail.com> <20091013182144.GA3338@del.dom.local> <cb00fa210910131125m17eca24cx4a912e75f91f0fd2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62797 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760941AbZJMSnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2009 14:43:09 -0400
Content-Disposition: inline
In-Reply-To: <cb00fa210910131125m17eca24cx4a912e75f91f0fd2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Oct 13, 2009 at 03:25:48PM -0300, Ivo Calado escreveu:
>      strange! I'm using the current DCCP test tree, branch dccp.
> Am I correct in use these rules?

Follow the rules in the latest Documentation/SubmittingPatches file,
that is:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob_plain;f=Documentation/SubmittingPatches;hb=HEAD

And that states:

-------------------------------------------------------------------

8) E-mail size.

When sending patches to Linus, always follow step #7.

Large changes are not appropriate for mailing lists, and some
maintainers.  If your patch, uncompressed, exceeds 300 kB in size,
it is preferred that you store your patch on an Internet-accessible
server, and provide instead a URL (link) pointing to your patch.

-------------------------------------------------------------------

As Jarek pointed out.

- Arnaldo
