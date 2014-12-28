From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: net.git: Call-trace after "Merge branch 'netlink_multicast'"
Date: Sun, 28 Dec 2014 10:39:04 +0100
Message-ID: <CA+icZUWfwqS8KiaO9T_vsnbwC7q8Sez4uHA-ierix0iezXKZRg@mail.gmail.com>
References: <CA+icZUVkNHBqCn66onJP9i5vfVzHR9mdSFXyiBFyjhkrySrSzQ@mail.gmail.com>
	<CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42064 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaL1JjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 04:39:06 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so19838170wiw.13
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 01:39:04 -0800 (PST)
In-Reply-To: <CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 28, 2014 at 7:22 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Sun, Dec 28, 2014 at 6:39 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> [ ... ]
>> [ CCing Fengguang Wu who reported the same issue on LKML (see [0]) ]
>>
>> Was "netlink/genetlink: pass network namespace to bind/unbind" patch
>> [1] forgotten in this 'netlink_multicast' merge?
>
> OK, this patch is additional and on top of "[PATCH 0/5]
> netlink/genetlink cleanups & multicast improvements"
>

Thanks, now I can see that patch in net.git#master.

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=023e2cfa36c31b0ad28c159a1bb0d61ff57334c8
