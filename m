From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 1/2] add bridge_slave device support
Date: Tue, 30 Sep 2014 10:05:18 +0200
Message-ID: <20140930080518.GB1864@nanopsycho.orion>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
 <1409925309-17881-1-git-send-email-jiri@resnulli.us>
 <CAJ3xEMgLaJtxuerfJ0OXGPZ7Hn0tVBJYkc5Ck6wOGvFAKyctCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	arvid.brodin@alten.se, sucheta.chakraborty@qlogic.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:38652 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaI3IFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 04:05:21 -0400
Received: by mail-we0-f180.google.com with SMTP id x48so3680333wes.39
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 01:05:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgLaJtxuerfJ0OXGPZ7Hn0tVBJYkc5Ck6wOGvFAKyctCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Sep 29, 2014 at 08:20:00PM CEST, gerlitz.or@gmail.com wrote:
>On Fri, Sep 5, 2014 at 4:55 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Note this depends on "iproute2: allow to change slave options via
>> type_slave"
>
>OK, but how about sparing few words what this patch does?

Sorry, I thought it is obvious. It allows to use IFLA_INFO_SLAVE_DATA to
get/set bridge port options.
