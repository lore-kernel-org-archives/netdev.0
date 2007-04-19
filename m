From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Getting the new RxRPC patches upstream
Date: Thu, 19 Apr 2007 09:50:42 -0600
Message-ID: <m1hcrcmkh9.fsf@ebiederm.dsl.xmission.com>
References: <m1lkgoms4j.fsf@ebiederm.dsl.xmission.com>
	<11769696211263-git-send-email-ebiederm@xmission.com>
	<m1slawn9eb.fsf@ebiederm.dsl.xmission.com>
	<29341.1176975158@redhat.com> <2969.1176992303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "<Andrew Morton" <akpm@osdl.org>, containers@lists.osdl.org,
	Oleg Nesterov <oleg@tv-sign.ru>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40112 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1766824AbXDSPwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 11:52:09 -0400
In-Reply-To: <2969.1176992303@redhat.com> (David Howells's message of "Thu, 19
	Apr 2007 15:18:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells@redhat.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> What is the ETA on your patches?
>
> That depends on Dave Miller now, I think.  I'm assuming they need to go
> through the network GIT tree to get to Linus.  Certainly Andrew Morton seems
> to think so.

Ok.  I don't see any patches in -mm so I was assuming these patches have
not been queued up anywhere.

As long as these things happen in a reasonably timely manner so I can
remove the export of kernel_thread and kill daemonize I really don't care.

If you have written them they are quite likely better then my minimal
patches which were quite restrained because of my limited ability to
test these things.

Eric
