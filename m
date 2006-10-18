From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [patch] d80211: remove initialization of unused xr structure members
Date: Wed, 18 Oct 2006 18:03:58 +0200
Message-ID: <200610181803.58946.IvDoorn@gmail.com>
References: <20061013193457.GA24280@devicescape.com> <20061018175525.2f946baa@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:25054 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161221AbWJRQFl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 12:05:41 -0400
Received: by nf-out-0910.google.com with SMTP id c2so711469nfe
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2006 09:05:40 -0700 (PDT)
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061018175525.2f946baa@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > The structure member xr_end was removed from d80211.h.
> 
> John, please apply this after you pull from my tree (perhaps with a
> rt2x00 prefix in the subject instead of d80211?).

The patch itself looked good, but it doesn't fix rt2500usb and rt73usb,
I will send a patch to fix the rt2x00 USB drivers shortly.

Ivo
