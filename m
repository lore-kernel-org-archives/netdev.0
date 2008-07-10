From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Thu, 10 Jul 2008 18:15:07 +0300
Message-ID: <1ba2fa240807100815j6bda3c63q4fc4d0c5da826fe3@mail.gmail.com>
References: <20080709190915.GA8238@tuxdriver.com>
	 <1215700309.3483.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Johannes Berg" <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:41166 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbYGJPPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 11:15:09 -0400
Received: by yx-out-2324.google.com with SMTP id 8so1095478yxm.1
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 08:15:08 -0700 (PDT)
In-Reply-To: <1215700309.3483.21.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008 at 5:31 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
>> 1500  Future work
>
> Maybe something about testing? Or I'll do a testing brainstorming
> session after dinner.
>
> Obviously, testing at orbit never worked out, but it'd be good to have
> _something_ other than everybody testing their thing locally. Ties in
> with the virtual hardware, maybe?
>
>From the driver perspective it would be loop back phy (tx/rx), The
peer side might be running on virtual HW. Currently it's not easy to
establish automated regression over the air. Good portion of the flows
can be tested this way.

I'm also looking for easier bug reporting for unexperienced users
maybe some uevent/HAL popping to application and emails it out/. Not
sure really how to handle this and not create spams. I'm just
expecting more real 'end users'.


Thanks
Tomas
