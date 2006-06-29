From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: [RFT PATCH] pcnet32:  NAPI support
Date: Thu, 29 Jun 2006 08:58:16 -0400
Message-ID: <20060629125816.GB1443@csclub.uwaterloo.ca>
References: <20060623213212.GA24388@us.ibm.com> <20060628144010.GA1446@csclub.uwaterloo.ca> <20060628165541.GA16601@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:20143 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S1750741AbWF2M6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 08:58:17 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060628165541.GA16601@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 28, 2006 at 09:55:41AM -0700, Don Fry wrote:
> Yes, I saw the debug statements when creating the email and was too lazy
> to remove them and create a new patch.  The patch needs to be broken up
> into functional pieces anyway, so since it has passed all of my testing
> as well, I will start on that...

So it might make 2.6.18 then? :)

I just updated the driver in my 2.6.16 kernel to the 2.6.17 version and
applied your patch, and then added my own weird stuff that no one else
will want.

Len Sorensen
