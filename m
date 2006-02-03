From: rhee@ncsu.edu
Subject: Re: FW: Performance evaluation of high speed TCPs
Date: Thu, 2 Feb 2006 21:50:07 -0500 (EST)
Message-ID: <48677.60.44.142.168.1138935007.squirrel@webmail.ncsu.edu>
References: <C0FF12BB5B83E44ABAEAA47149DA973508266A@helios.eee.strath.ac.uk>
	<C0FF12BB5B83E44ABAEAA47149DA973508266D@helios.eee.strath.ac.uk>
	<39307.60.44.142.168.1138932213.squirrel@webmail.ncsu.edu>
	<C0FF12BB5B83E44ABAEAA47149DA9735082675@helios.eee.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, end2end-interest@postel.org
Return-path: <end2end-interest-bounces@postel.org>
In-Reply-To: <C0FF12BB5B83E44ABAEAA47149DA9735082675@helios.eee.strath.ac.uk>
To: "Douglas Leith" <doug@eee.strath.ac.uk>
List-Unsubscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://www.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org


Sure. Your comments about running the buggy implementation are well taken.
That is
why this type of reporting is helpful and we are committed to keep this
effort. Just that
it takes time to run the tests, and before we run a new set of tests, we
have to do some
batch of patches to reduce our effort level (but in this case of the HTCP
bug, rest assured
that we are running it now..it is just that there are a lot of other
things going on
that we have to catch a breath a little).

Then again, if we don't do the test and keep the report
up-to-date then it is difficult to find bugs as well...so these reportings
help us find
bugs and also improve TCP algorithms. (I hope our report did the same for
you).  Also
sometimes we are not motivated to find the bugs ourselves.

In fact, i contacted your student "Baruch" one month and half before  we
posted our
report -- it was CCed in the netdev mailing list as well and we gave him
login and
passwd on our result website (at that time we were just about to write the
report)
and we have not heard from your guys until just one week ago. At least we
did try to
make sure we are running a buggy version.




>>Seriously, we can't run the tests for every fix and bug report.
>
> Perhaps best to view it as returning a favour.  You may recall that we
> re-ran all our own experimental tests last year (all data and code
> available online at www.hamilton.ie/net/eval/) on discovering a previously
> unreported bug introduced by the linux folks when implementing bic.
> Something similar has happened with importing htcp into linux.
>
> Seriously, where's the value in comparing buggy implementations - isn't
> that just a waste of all our time ?  If we are genuine about wanting to
> understand tcp performance then I think we just have to take the hit from
> issues such as this that are outside all of our control.
>
> Doug
>
> Hamilton Institute
> www.hamilton.ie
>
