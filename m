From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: IPsec AH use of ahash
Date: Fri, 18 Jan 2013 19:59:55 -0800
Message-ID: <1358567995.3464.372.camel@edumazet-glaptop>
References: <20130118221614.GA5616@ppwaskie-mobl2.amr.corp.intel.com>
	 <1702471741.91455.1358548305936.JavaMail.root@elliptictech.com>
	 <20130119023355.GB10964@lion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom St Denis <tstdenis@elliptictech.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:55238 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342Ab3ASEAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 23:00:02 -0500
In-Reply-To: <20130119023355.GB10964@lion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-01-19 at 03:33 +0100, Michal Kubecek wrote:

> Someone already pointed you to http://patchwork.ozlabs.org/
> Please do take a look there. I just did and found that in last three
> months, about 3500 patches were submitted to this list, i.e. about
> 40 patches per day (including weekends and Christmas). All of these need
> to be reviewed by a few maintainers who are also doing their part of
> development. How do they manage to handle it, honestly I don't know.

I want to make here a huge thanks to David Miller, and of course
to all contributors.

I truly believe we did very well, and I really hope new contributors
will come and continue the impressive work.

Sure, sometime we can react not as good as we could do if we were
not overloaded. (I mean, 6 hours listening Lance Amstrong confession.
You really cant avoid such a scoop !)

I understand that for a new contributor, it might be difficult to
catch up with various rules, but reading netdev archives should be
enough to understand how it really works. Its not like the process
was a secret.

Tom, even a maintainer can make errors, thats not a big deal, as long
as things can go forward.

If you felt you had 0% chance to get your patch being accepted, then
you had a wrong feeling.

If the patch makes sense and you agree to address reviewers feedback, it
definitely can be accepted. If you think you don't have time to do that,
then maybe the patch is not really needed.
