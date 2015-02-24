From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [RFC PATCH 01/29] fib_trie: Convert fib_alias to hlist from list
Date: Tue, 24 Feb 2015 14:14:02 -0800
Message-ID: <54ECF7AA.6000509@redhat.com>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>	<20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>	<CAJ3xEMhn6R9heFGtEB4-uxb2SHc2XWZv2oX_7pYhZVYZo5MeFw@mail.gmail.com> <20150224.170819.1223923082073420924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351AbbBXWOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 17:14:06 -0500
In-Reply-To: <20150224.170819.1223923082073420924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 02/24/2015 02:08 PM, David Miller wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Tue, 24 Feb 2015 23:51:40 +0200
>
>> On Tue, Feb 24, 2015 at 10:48 PM, Alexander Duyck
>> <alexander.h.duyck@redhat.com> wrote:
>>> There isn't any advantage to having it as a list and by making it an hlist
>>> we make the fib_alias more compatible with the list_info in terms of the
>>> type of list used.
>> Hi Alex, twenty nine patches without (unless it's on his way) cover
>> letter are really hard to grasp, can you write something general on
>> this series, please...
> There was a 00/29 posting.

Yeah, Or saw it.  It just showed up late I am guessing.  Even in my own 
inbox it takes a few minutes for all of the patches to show up when I 
post a set.

- Alex
