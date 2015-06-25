From: Joe Perches <joe@perches.com>
Subject: Re: [GIT] Networking
Date: Thu, 25 Jun 2015 09:52:18 -0700
Message-ID: <1435251138.9377.28.camel@perches.com>
References: <20150624.063911.1220157256743743341.davem@davemloft.net>
	 <CA+55aFybr6Fjti5WSm=FQpfwdwgH1Pcfg6L81M-Hd9MzuSHktg@mail.gmail.com>
	 <CAP=VYLogXORmUN1bt1++ucmTOp=T-nJd2pve0-ufV+HQaCVy6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP=VYLogXORmUN1bt1++ucmTOp=T-nJd2pve0-ufV+HQaCVy6Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-06-25 at 12:24 -0400, Paul Gortmaker wrote:
> On Wed, Jun 24, 2015 at 7:38 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > I'm getting *real* tired of that BUG_ON() shit.
[]
> > Killing the machine for idiotic things like that is truly offensive,
> > and truly horrible horrible code. Why do I keep on having to tell
> > people off for doing these things? Why do people keep thinking that
> > debugging-by-killing-the-machine is a good idea?
> 
> Ingo figured this was an educational battle that we'd never win.
> 
> https://lkml.org/lkml/2014/5/21/490

That should still be applied but for the selfie/OED bit as
selfie is in the OED now...
