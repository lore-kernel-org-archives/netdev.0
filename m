From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: 2nd REVISED AGENDA -- Re: Linux Wireless Mini-Summit -- Ottawa -- July 22, 2008
Date: Thu, 17 Jul 2008 03:16:07 -0700
Message-ID: <43e72e890807170316xcd6528cpcef4a8f669a22d08@mail.gmail.com>
References: <20080709190915.GA8238@tuxdriver.com>
	 <20080715182654.GA5969@tuxdriver.com>
	 <20080716184803.GB3232@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:41090 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbYGQKQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 06:16:08 -0400
Received: by an-out-0708.google.com with SMTP id d40so147073and.103
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 03:16:07 -0700 (PDT)
In-Reply-To: <20080716184803.GB3232@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 11:48 AM, John W. Linville
<linville@tuxdriver.com> wrote:

> I'm still looking for more/different topics

A couple I can think of:

* Compat-wireless, this can be discussed after new MQ patch. We may
have to freeze mac80211 for old kernels for compat-wireless after the
MQ patch goes through and only leave in it fixes moving forward. This
consideration is because porting the MQ patch may be very difficult to
maintain. It was expected though that the first MQ patch could not be
ported though so we'll see, we just might be able to port this
properly. We can talk about this further at the summit.

* Testing -- lets get serious about automation of testing. The Orbit
grid is still available, we just need to put together scripts and test
scenarios.

* Rate control cleanup -- this needs to a good review and cleanup.
Probably not high on our priority list though. We can talk about this
further during the "rate scaling algs" section on the agenda.

  Luis
