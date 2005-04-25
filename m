From: "David S. Miller" <davem@davemloft.net>
Subject: Re: NAPI, e100, and system performance problem
Date: Mon, 25 Apr 2005 11:51:08 -0700
Message-ID: <20050425115108.5fbb8b07.davem@davemloft.net>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
	<1114173195.7679.30.camel@localhost.localdomain>
	<20050422172108.GA10598@muc.de>
	<1114193902.7978.39.camel@localhost.localdomain>
	<20050422183004.GC10598@muc.de>
	<Pine.LNX.4.61.0504221131350.15052@linux.site>
	<20050422115230.6037a362.davem@davemloft.net>
	<Pine.LNX.4.61.0504241845070.2934@linux.site>
	<1114428355.7669.157.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, Robert.Olsson@data.slu.se, ak@muc.de, gnb@sgi.com,
        jesse.brandeburg@intel.com, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1114428355.7669.157.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 25 Apr 2005 07:25:55 -0400
jamal <hadi@cyberus.ca> wrote:

> Dang, I just noticed you used TCP. Could you use UDP please?
> 
> While the suspect may be PIO/s - lets be scientific and prove it.

Jamal, enough already... stop being such a control freak.
You're exceeding me as a control freak, and that's saying
something.

The guy got the numbers for us, in response to their claim that
on their systems cpu utilization is poor due to NAPI.  Are you
not convinced of this yet?

Will a hundred new sets of numbers using the precise driver and
protocol of your choosing convince you more of this?  I think
you're making unreasonable reqeusts of the problem submitter at
this point, and we should be sending them patches to test not
a new set of tests to run.
