From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Thu, 30 May 2013 10:07:47 -0700
Message-ID: <20130530100747.5b9c7893@nehalam.linuxnetplumber.net>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
	<ko4kcr$h8j$1@ger.gmane.org>
	<CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
	<20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
	<CAF1J0HNiBED=BLHqPPk8w2=DDvSWdZwMPvtag6rpPhxnboT4GA@mail.gmail.com>
	<20130530114424.GC10532@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mike Rapoport <mike.rapoport@ravellosystems.com>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:59310 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758408Ab3E3RHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 13:07:51 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so704947pdj.29
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 10:07:51 -0700 (PDT)
In-Reply-To: <20130530114424.GC10532@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 May 2013 12:44:24 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> > Say, misc/vxlan that will handle remote destinations management? Or
> > should it take care of some vxlan parameters currently implemented in
> > ip/iplink_vxlan and bridge/fdb?  
> 
> What do we gain from a separate tool?

At some point the syntax becomes unwieldy, could even just be a shell script.
