From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net 1/2] sch_pie: schedule the timer after all init succeed
Date: Fri, 24 Oct 2014 17:42:50 -0700
Message-ID: <CAHA+R7M0ErNCMMtU5brJpQdCSW4+epniDHg__s=B2uqX0UZT0w@mail.gmail.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
	<1414196222.20845.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7PFSCACHyrU8fa4PVLOF1OtJiFiw4peLmFPzEu6-adaeQ@mail.gmail.com>
	<1414197563.20845.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vijay Subramanian <vijaynsu@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:58947 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932402AbaJYAmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 20:42:51 -0400
Received: by mail-qg0-f43.google.com with SMTP id j107so1811140qga.30
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2014 17:42:50 -0700 (PDT)
In-Reply-To: <1414197563.20845.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 5:39 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> You don't need to add one line in the changelog.
>
> Why would it be needed ? Think about it.


Simply because git-send-email reads Cc: so that I don't have to
specify in cmdline.
That's all.

OMG, first time to hear people complaining on Cc'ing too much! lol :)
