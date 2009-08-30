From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Reduce looping in the interrupt handler.
Date: Sun, 30 Aug 2009 22:37:35 +0200
Message-ID: <20090830203735.GA24912@electric-eye.fr.zoreil.com>
References: <1251294974.14241.9.camel@obelisk.thedillows.org> <1251295175.14241.11.camel@obelisk.thedillows.org> <m11vmy737x.fsf@fess.ebiederm.org> <20090826213024.GA20428@electric-eye.fr.zoreil.com> <m1hbvu45jq.fsf@fess.ebiederm.org> <20090827052423.GA1709@electric-eye.fr.zoreil.com> <m1ocq1ke9u.fsf@fess.ebiederm.org> <20090827232024.GA30119@electric-eye.fr.zoreil.com> <m1d46gka9e.fsf@fess.ebiederm.org> <1251422978.21865.2.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B??ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754107AbZH3UiF@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1251422978.21865.2.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Dillow <dave@thedillows.org> :
[...]
> It'll be this weekend, but I can see cases where it can lock my chip up
> -- they should be rare, but then I thought your case would be extremely
> rare...

I don't get it.

Can you elaborate the relevant cases or give some sample scenarios for
them ?

-- 
Ueimor
