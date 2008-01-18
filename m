From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] IPv6 support for NFS server
Date: Fri, 18 Jan 2008 17:55:43 -0500
Message-ID: <20080118225543.GB9754@fieldses.org>
References: <475D86C1.6070400@ext.bull.net> <475EBDB4.5020108@hp.com> <475ED028.2010109@ext.bull.net> <20080115223221.GE5028@fieldses.org> <20080115231636.GB19658@fieldses.org> <478F8AA3.9060707@ext.bull.net> <20080117203857.GB6416@fieldses.org> <4790BCD0.30905@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev ML <netdev@vger.kernel.org>,
	Brian Haley <brian.haley@hp.com>,
	Mailing list NFSv4 <nfsv4@linux-nfs.org>
To: =?utf-8?B?QXVyw6lsaWVu?= Charbon <aurelien.charbon@ext.bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760153AbYARWzp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 17:55:45 -0500
Content-Disposition: inline
In-Reply-To: <4790BCD0.30905@ext.bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2008 at 03:50:56PM +0100, Aur=C3=A9lien Charbon wrote:
> OK Bruce I have added this comment before the patch.
> I have also done the changes pointed by Brian.
> Please let me know if there is still something to change.

Thanks.  For the future, if you could just make the comment part of the
actual git commit, that'll help produce a patch that can be fed to my
scripts with less hassle....

Anyway, looks fine to me, applied.  (But I may wait till 2.6.26 to
submit.)

--b.
