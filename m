From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Automated linux kernel testing results
Date: Mon, 06 Jun 2005 11:30:48 -0700
Message-ID: <42A49658.7060608@us.ibm.com>
References: <20050604050123.9897.qmail@web31504.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jonathan Day <imipak@yahoo.com>
In-Reply-To: <20050604050123.9897.qmail@web31504.mail.mud.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jonathan Day wrote:

> What I have not (yet) seen is any work on relating the
> results. Is a bug in the design? The implementation?
> Some combination thereof? Is something correctly
> written but not functioning because something it
> depends on isn't working correctly?

Currently, you can get some idea (kernel didn't
build, machine couldn't reboot, or if the system
crashes during the tests, crash info etc.  Looking
into whether the cause is a design bug or an
implementation bug is likely beyond automation.

> It would even be useful if we could cross-reference
> some of the benchmarks with the Linux graphing
> project, so that we could see how the complexity of

I believe they do (ping Martin for details) have some
plans to graph stuff, and possibly info could be sucked
out of the data/results provided to feed other people's
needs.

> Test suites are necessary. Test suites are great.
> Anyone working on a test suite deserves many kudos and
> much praise. Test suites that are relatable enough
> that you can see the same problem from different
> angles -- those are worth their printout weight in
> gold.

Yeah. :).

thanks,
Nivedita
