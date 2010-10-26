From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] Add support for new VLAN acceleration model
Date: Mon, 25 Oct 2010 19:22:00 -0700
Message-ID: <AANLkTi=kYH2NLMChuzd=OF6TPyn8FPJaRLfBg7z1gcYq@mail.gmail.com>
References: <1287951880-25321-1-git-send-email-dave@thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, jgarzik@redhat.com, davem@davemloft.net
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33041 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756200Ab0JZCWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 22:22:02 -0400
Received: by wwe15 with SMTP id 15so4222975wwe.1
        for <netdev@vger.kernel.org>; Mon, 25 Oct 2010 19:22:00 -0700 (PDT)
In-Reply-To: <1287951880-25321-1-git-send-email-dave@thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 1:24 PM, David Dillow <dave@thedillows.org> wrote:
> Signed-off-by: David Dillow <dave@thedillows.org>
> ---
> I used this during testing of the typhoon conversion.

Oops, I have a nearly identical patch that I should have sent out
earlier to make everyone's lives easier.  The only differences in mine
are some man page updates and grouping the vlan settings a little more
closely with the other forms of offloading (as opposed to
filtering/hashing).  I guess I'll post my version as well (since we
should at least be sure to update the man page) in case that is more
convenient.  I don't mean to steal the credit though.
