From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH 01/29] fib_trie: Convert fib_alias to hlist from list
Date: Tue, 24 Feb 2015 23:51:40 +0200
Message-ID: <CAJ3xEMhn6R9heFGtEB4-uxb2SHc2XWZv2oX_7pYhZVYZo5MeFw@mail.gmail.com>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
	<20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:60890 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbbBXVvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:51:40 -0500
Received: by mail-ob0-f181.google.com with SMTP id vb8so46405315obc.12
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:51:40 -0800 (PST)
In-Reply-To: <20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 10:48 PM, Alexander Duyck
<alexander.h.duyck@redhat.com> wrote:
> There isn't any advantage to having it as a list and by making it an hlist
> we make the fib_alias more compatible with the list_info in terms of the
> type of list used.

Hi Alex, twenty nine patches without (unless it's on his way) cover
letter are really hard to grasp, can you write something general on
this series, please...
