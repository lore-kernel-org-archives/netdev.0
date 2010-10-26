From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] Add support for new VLAN acceleration model
Date: Mon, 25 Oct 2010 22:48:11 -0400
Message-ID: <1288061291.21198.9.camel@obelisk.thedillows.org>
References: <1287951880-25321-1-git-send-email-dave@thedillows.org>
	 <AANLkTi=kYH2NLMChuzd=OF6TPyn8FPJaRLfBg7z1gcYq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@redhat.com, davem@davemloft.net
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amavis-smtp.knology.net ([75.76.199.6]:47516 "EHLO
	amavis-smtp.knology.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757094Ab0JZCsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 22:48:22 -0400
In-Reply-To: <AANLkTi=kYH2NLMChuzd=OF6TPyn8FPJaRLfBg7z1gcYq@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-25 at 19:22 -0700, Jesse Gross wrote:
> On Sun, Oct 24, 2010 at 1:24 PM, David Dillow <dave@thedillows.org> wrote:
> > Signed-off-by: David Dillow <dave@thedillows.org>
> > ---
> > I used this during testing of the typhoon conversion.
> 
> Oops, I have a nearly identical patch that I should have sent out
> earlier to make everyone's lives easier.

Would have saved me a few minutes, but don't sweat it -- it took me
forever to figure out that my WRT54G was stripping VLAN tags, making it
look like the driver had been broken for quite some time...

As for the credit, I'm not at all concerned; I think I like your patch
better anyway.

