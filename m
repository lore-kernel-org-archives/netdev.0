From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC PATCH 3/5] Rename support library for geneve
Date: Thu, 2 Apr 2015 17:05:26 -0700
Message-ID: <CAHA+R7Op9inHY=CvyyqgK4v7=xxntAPmZBzBYg27hxcKFF7H6A@mail.gmail.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
	<1428002227-11636-4-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:32814 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbbDCAF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 20:05:27 -0400
Received: by iebmp1 with SMTP id mp1so74193080ieb.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 17:05:26 -0700 (PDT)
In-Reply-To: <1428002227-11636-4-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 2, 2015 at 12:17 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> net/ipv4/geneve.c -> net/ipv4/libgeneve.c
>
> This name better reflects the purpose of the module.

There are several files under net/ipv4/ used as a library,
there is no reason to just highlight this single one. So
this change is not necessary at all.
