From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/8] textsearch: fix textsearch for case insensitive searching
Date: Tue, 24 Jun 2008 14:27:36 +0200
Message-ID: <4860E838.6090508@trash.net>
References: <1214034838-1270-1-git-send-email-joonwpark81@gmail.com> <485CB9F6.6050601@trash.net> <20080623232224.GG20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Joonwoo Park <joonwpark81@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50294 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbYFXM1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 08:27:41 -0400
In-Reply-To: <20080623232224.GG20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2008-06-21 10:21
>> This looks fine to me, although a generic flags argument
>> would prevent changing all users again next time someone
>> wants to add a feature. But I'll leave that decision to
>> Thomas.
> 
> I agree, I'd favour a general flag for this as well.


Joonwoo, if you send me a replacement patch that uses a flag
instead I'm going to apply the entire series.
