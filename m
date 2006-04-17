From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] Fix crash on big-endian systems during scan
Date: Mon, 17 Apr 2006 10:34:03 -0400
Message-ID: <1145284443.2212.5.camel@localhost.localdomain>
References: <20060414215911.17273.40460.stgit@dv.roinet.com>
	 <20060417010602.GL9551@jm.kir.nu>  <20060417132105.GF5042@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51437 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751026AbWDQOfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 10:35:46 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060417132105.GF5042@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-17 at 09:21 -0400, John W. Linville wrote:
> On Sun, Apr 16, 2006 at 06:06:02PM -0700, Jouni Malinen wrote:
> > On Fri, Apr 14, 2006 at 05:59:11PM -0400, Pavel Roskin wrote:
> > 
> > > The original code was doing arithmetics on a little-endian value.
> > 
> > John, please apply this to wireless-2.6 tree. This code is triggered at
> > least for the case where WPA is not used. I had noticed it before, but I
> > think I've only tested WPA/WPA2 on big endian systems..
> 
> Can someone repost this patch?  I seem to have missed it.

Pavel posted to netdev originally on Friday April 14th with the patch
included in the email, with the title "[PATCH] Fix crash on big-endian
systems during scan"...

http://www.spinics.net/lists/netdev/msg03023.html

Sure you don't have it somewhere?  If not, I'm sure somebody can
resend...

Dan


