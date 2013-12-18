From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net v2 5/9] bridge: Fix the way to check if a local fdb
 entry can be deleted
Date: Wed, 18 Dec 2013 10:04:42 -0800
Message-ID: <20131218100442.7536b966@nehalam.linuxnetplumber.net>
References: <1387281821-21342-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1387281821-21342-6-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<52B09DB2.7040700@redhat.com>
	<1387341972.3563.71.camel@ubuntu-vm-makita>
	<52B1D9E6.7020201@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60253 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753427Ab3LRSEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 13:04:46 -0500
Received: by mail-pa0-f51.google.com with SMTP id fa1so6258228pad.24
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 10:04:45 -0800 (PST)
In-Reply-To: <52B1D9E6.7020201@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Dec 2013 12:22:46 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> I'll let Stephen or David weigh in with their opinions.

I am fine with how you guys are working out the solution.
When you come to a final conclusion, I will give it one last look.
