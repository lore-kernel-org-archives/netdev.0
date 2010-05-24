From: Julien BLACHE <jb@jblache.org>
Subject: Re: [regression] fib6_del() bug from 2.6.34-rc1 still present in 2.6.34
Date: Mon, 24 May 2010 11:54:20 +0200
Message-ID: <878w7962wj.fsf@sonic.technologeek.org>
References: <87632g53tx.fsf@sonic.technologeek.org>
	<4BF9DCB7.8040308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ix.technologeek.org ([213.41.157.215]:35104 "EHLO
	sonic.technologeek.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752364Ab0EXJy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 05:54:27 -0400
In-Reply-To: <4BF9DCB7.8040308@cn.fujitsu.com> (Shan Wei's message of "Mon, 24
	May 2010 09:56:07 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei <shanwei@cn.fujitsu.com> wrote:

Hi,

> I saw the warning on 2.6.34-rc3. But on net-next tree the warning disappeared.
> So I think the bug is fixed in net-next tree. My NIC driver is r8169.
>
> The net-next tree is newer than 2.6.34, maybe the fix is not queued to 2.6.34.
> So the warning also be present in 2.6.34.
> Can you try net-next tree firstly?

Unfortunately, this tree has a number of issues that prevent a
successful boot into userland on my machine :/

Any idea what the fix(es) is so I can test it out?

JB.

-- 
Julien BLACHE                                   <http://www.jblache.org> 
<jb@jblache.org>                                  GPG KeyID 0xF5D65169
