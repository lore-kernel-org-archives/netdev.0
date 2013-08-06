From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Tue, 6 Aug 2013 23:39:26 +0300
Message-ID: <CAJZOPZKByh7LzH0w25dDG_5jOvg7wPrmiVcMJ0xBhOJxaE0Zcw@mail.gmail.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
	<5200A8BC.4010402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:44012 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755705Ab3HFUqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 16:46:18 -0400
Received: by mail-qc0-f180.google.com with SMTP id j10so480858qcx.25
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 13:46:17 -0700 (PDT)
In-Reply-To: <5200A8BC.4010402@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 6, 2013 at 10:41 AM, Eliezer Tamir
<eliezer.tamir@linux.intel.com> wrote:
> On 06/08/2013 00:22, Shawn Bohrer wrote:
>> 1) I'm testing with a Mellanox ConnectX-3 card.
>
> There's your problem ;)

Can you be more specific? I love testing with Intel Niantic, do code
inspetion of the ixgbe driver and interact with Jeff/Greg/Alex/John
and all the other great folks from the Intel Linux networking team,
actually that (happily working with your competitors) is crucial part
of the fun in open source / upstream work. What's wrong with using
NICs which don't have intel.com on their paper cover?

Or.
