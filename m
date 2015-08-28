From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC] openvswitch: Retain parsed IPv6 header fields in
 flow on error skipping extension headers
Date: Sat, 29 Aug 2015 08:31:27 +0900
Message-ID: <20150828233125.GB22130@penelope.isobedori.kobe.vergenet.net>
References: <1439515813-29406-1-git-send-email-simon.horman@netronome.com>
 <CALnjE+owxmLQXLZoAU4oNXToDA1hb4uvr8nj9KXCiKgcRhEOvQ@mail.gmail.com>
 <20150827070959.GA25311@vergenet.net>
 <CALnjE+qPPoguVDAmCozjqp5bS3aGO72Y0oxUM45=C1OOdXx28Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Gross <jesse@nicira.com>, netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35205 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbbH1Xbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 19:31:32 -0400
Received: by pacdd16 with SMTP id dd16so76637136pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 16:31:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALnjE+qPPoguVDAmCozjqp5bS3aGO72Y0oxUM45=C1OOdXx28Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 11:11:08AM -0700, Pravin Shelar wrote:

[snip]

> Looks good to me.

Thanks, I will make a formal submission of it as v2.
