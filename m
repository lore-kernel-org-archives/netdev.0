From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: private netdev flags into UAPI?
Date: Tue, 27 Nov 2012 00:29:55 +0200
Message-ID: <CAJZOPZLQSCNTfSm63z1P_S4ZmwL+9mbP7rOCH7yHgBFcjaz1UA@mail.gmail.com>
References: <50B1CC1B.20104@mellanox.com>
	<10845.1353921761@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev <netdev@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:47470 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087Ab2KZW35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:29:57 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so8474869iay.19
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2012 14:29:56 -0800 (PST)
In-Reply-To: <10845.1353921761@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 26, 2012 at 11:22 AM, David Howells <dhowells@redhat.com> wrote:
> They were exposed to userspace already

So the script carries the bug into a new directory... why? AFAIK,
intentionally there's no way to read private flags from user space, so
what's the point in defining them there?

Or.
