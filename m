From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pcnet32: remove superfluous NULL pointer check in
 pcnet32_probe1()
Date: Tue, 04 Aug 2009 06:03:54 -0700 (PDT)
Message-ID: <20090804.060354.66058154.davem@davemloft.net>
References: <200908022207.29942.bzolnier@gmail.com>
	<20090802.131256.210461366.davem@davemloft.net>
	<200908041233.02016.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, error27@gmail.com, corbet@lwn.net,
	eteo@redhat.com, julia@diku.dk
To: bzolnier@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755507AbZHDNDr@vger.kernel.org>
In-Reply-To: <200908041233.02016.bzolnier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Date: Tue, 4 Aug 2009 12:32:56 +0200

> On Sunday 02 August 2009 22:12:56 David Miller wrote:
>> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
>> Date: Sun, 2 Aug 2009 22:07:29 +0200
>> 
>> > netdev@vger.kernel.org was on cc: for all patches...
>> > 
>> > http://marc.info/?l=linux-netdev&m=124898901714229&w=2
>> > http://marc.info/?l=linux-netdev&m=124898901714236&w=2
>> > 
>> > maybe there is some problem with a patchwork setup..
>> 
>> My bad, I misread the CC: list, sorry.
> 
> There still may be some netdev patchwork problem..
> 
> These patches were applied with Don as an author:

It's because he forwarded them to netdev when he ACK'd them, and those
are the ones the postings that actually showed up properly in
patchwork, and thus the From: lines that got used for authorship.

Sorry, I should have caught that.
