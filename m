From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] NetLabel: use SECINITSID_UNLABELED for a base SID
Date: Thu, 5 Oct 2006 21:46:06 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610052145030.29449@d.namei>
References: <20061005222823.387569000@hp.com> <20061005223704.067757000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:62178 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932562AbWJFBqI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 21:46:08 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20061005223704.067757000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Oct 2006, paul.moore@hp.com wrote:

> This patch changes NetLabel to use SECINITSID_UNLABLELED as it's source of
> SELinux type information when generating a NetLabel context.

Applied.


Git:
git://git.infradead.org/~jmorris/selinux-2.6.git

Web:
http://git.infradead.org/?p=users/jmorris/selinux-2.6.git;a=summary




-- 
James Morris
<jmorris@namei.org>
