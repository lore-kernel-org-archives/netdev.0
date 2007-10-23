From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 16:03:38 -0700
Message-ID: <471E7DCA.9030700@intel.com>
References: <11931515302013-git-send-email-ajax@redhat.com> <471E1ECD.80002@intel.com> <1193156487.26974.39.camel@localhost.localdomain> <471E2AD0.1000500@intel.com> <471E5C21.8030908@garzik.org> <20071023212026.GF7793@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Dave Jones <davej@redhat.com>, Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Adam Jackson <ajax@redhat.com>, linux-kernel@vger.kernel.org,
	David Miller <davem
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:61819 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbXJWXEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 19:04:08 -0400
In-Reply-To: <20071023212026.GF7793@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> On Tue, Oct 23, 2007 at 04:40:01PM -0400, Jeff Garzik wrote:
> 
>  > > In any case, this patch should not be merged. We often send it around to users to
>  > > debug their issue in case it involves eeproms, but merging it will just conceal
>  > > the real issue and all of a sudden a flood of people stop reporting *real* issues
>  > > to us.
>  > 
>  > Sorry, I disagree.  Just as with e100, if there is a clear way the user 
>  > can recover their setup -- and Adam says his was effective -- I don't 
>  > see why we should be denying users the ability to use their own hardware.
>  
> Indeed. This is a common enough problem that not including it causes more pain
> than its worth.  I have two affected boxes myself that I actually thought
> the hardware was dead before I tried ajax's patch.


look: You should have reported this to us and you didn't. Now you are using the
fact that you did not report it as an argument which is out of place.

why do you say it is common? how often have you seen this and not reported it back
to our support? are you willingly trying to frustrate this issue?


Auke
