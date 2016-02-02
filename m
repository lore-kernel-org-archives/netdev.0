From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH 3/7] net: sched: add cls_u32 offload hooks for netdevs
Date: Wed, 3 Feb 2016 00:06:56 +0200
Message-ID: <CAJ3xEMh2gUiEb1uoAYw-g2qAv5n5nAtDfP6WU4g=eqLq5gyBGQ@mail.gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
	<20160201015023.13871.69865.stgit@john-Precision-Tower-5810>
	<CAJ3xEMjRRUgHo_J4yQr3Z9wSJA7aRAzHc1ZNoBVP5WRmDFTRjw@mail.gmail.com>
	<56B0DC86.7090402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, ast@fb.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Simon Horman <horms@verge.net.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:33700 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752882AbcBBWG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 17:06:57 -0500
Received: by mail-io0-f175.google.com with SMTP id f81so34134683iof.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 14:06:56 -0800 (PST)
In-Reply-To: <56B0DC86.7090402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 2, 2016 at 6:42 PM, John Fastabend
<john.fastabend@gmail.com> > [..] I added
> flower support to the driver with about 100lines of code fwiw I'll
> send the patch out later today,

that would be very helpful, would appreciate if you post the code that
supports flower to the list or @ your github

> sure I skipped populating all the
> fields by breaking out of some case statements but not that many.
