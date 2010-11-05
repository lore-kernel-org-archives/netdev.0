From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.36 vlans & bridge crash - status?
Date: Fri, 5 Nov 2010 08:05:17 -0700
Message-ID: <AANLkTin130xsLRQRMH2W6Yy=gJSD-qS29vR-E6Qvfgpg@mail.gmail.com>
References: <20101105103520.GA3577@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev list <netdev@vger.kernel.org>, nikola.ciprich@linuxbox.cz
To: Nikola Ciprich <extmaillist@linuxbox.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42419 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab0KEPFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 11:05:19 -0400
Received: by wwb39 with SMTP id 39so1500057wwb.1
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 08:05:18 -0700 (PDT)
In-Reply-To: <20101105103520.GA3577@pcnci.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 5, 2010 at 3:35 AM, Nikola Ciprich <extmaillist@linuxbox.cz> wrote:
> Hello,
> I would like to ask if somebody is trying to solve
> https://bugzilla.kernel.org/show_bug.cgi?id=20462
> and if needed, could I provide some help, testing etc?

I sent out a patch for something related:
http://permalink.gmane.org/gmane.linux.network/176566

My guess is that it will also fix your issue.  Can you test it?
