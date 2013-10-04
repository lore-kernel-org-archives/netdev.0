From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH] ip: Showing peer of veth type dev in ip link (ip cmd
 side)
Date: Sat, 05 Oct 2013 03:42:41 +0900 (JST)
Message-ID: <20131005.034241.1270344813613892018.yamato@redhat.com>
References: <1380859565-32388-1-git-send-email-yamato@redhat.com>
	<20131004112350.06818715@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995Ab3JDSmo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Oct 2013 14:42:44 -0400
In-Reply-To: <20131004112350.06818715@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you those who review my patch and give me comments.
I'll revise the patch.

Forgive me sending the same patches twice accidentally.

Masatake YAMATO

> On Fri,  4 Oct 2013 13:06:05 +0900
> Masatake YAMATO <yamato@redhat.com> wrote:
> 
>> Implement print_opt method to veth to show peer ifindex
>> as ethtool -S does.
>> 
>> A patch submitted with following subject is needed:
>> 
>>    veth: Showing peer of veth type dev in ip link (kernel side)
>> 
>> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> 
> NAK, see kernel comments
