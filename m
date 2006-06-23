From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC] sysfs + configfs on 802.11 wireless drivers
Date: Fri, 23 Jun 2006 08:47:02 -0400
Message-ID: <20060623124657.GA3256@tuxdriver.com>
References: <43e72e890606220512h5197d473s5f7da9e734814005@mail.gmail.com> <1151063447.2473.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>, netdev@vger.kernel.org,
	Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:17166 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932565AbWFWMrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 08:47:24 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1151063447.2473.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 07:50:47AM -0400, Dan Williams wrote:

> Our effort is probably better spent elsewhere, especially since many
> popular userspace tools already handle resume for us just fine.  More
> useful to have drivers just come back from resume in an initialized
> state similar to system boot.

I think Dan makes a lot of sense here.  Does anyone disagree?

John
-- 
John W. Linville
linville@tuxdriver.com
