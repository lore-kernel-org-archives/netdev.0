From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Linux XIA - merge proposal
Date: Tue, 03 Mar 2015 17:33:18 -0600
Message-ID: <87a8ztwta9.fsf@x220.int.ebiederm.org>
References: <54F5EF6E.9090303@digirati.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michel Machado <michel@digirati.com.br>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F5EF6E.9090303@digirati.com.br> (Michel Machado's message of
	"Tue, 03 Mar 2015 12:29:18 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michel Machado <michel@digirati.com.br> writes:

>    Linux XIA is not yet mature enough for production, but we do think
> that broader exposure will help us to move forward faster, and get
> more in tune with the interested community. Thus, we are writing to
> ask to merge our work into the Linux kernel.

I took a quick glance at the code to see if could figure out what
you were talking about.   Especialy as I could not find any documents
on the packet format.  The code does not transmit packets.  All of the
packet transmit functions are stubs.  I can think of no greater failure
for a networking protocol.

Since the code does nothing except have buzz-word compliant descriptions
that are content free I respectfully suggest you make it mostly work
before foisting it on people.

My advice for a future day when you have code that can transmit packets
is to start small.  Have patches that do things and do them clearly.
Once you have a minimal version of working code merged then work your
way up.

For just sharing your code you might simply want to have your own tree
that you publish publicly.

Eric
