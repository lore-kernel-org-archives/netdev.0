From: jamal <hadi@cyberus.ca>
Subject: Re: Hard freeze with 2.6.10-rc3 and QoS, worked fine with 2.6.9
Date: 08 Dec 2004 10:05:05 -0500
Message-ID: <1102518304.1023.6.camel@jzny.localdomain>
References: <1102380430.6103.6.camel@buffy>
	 <20041206224441.628e7885.akpm@osdl.org>
	 <1102422544.1088.98.camel@jzny.localdomain> <41B5E188.5050800@trash.net>
	 <20041207170748.GF1371@postel.suug.ch> <41B5E722.2080600@trash.net>
	 <1102480044.1050.9.camel@jzny.localdomain>
	 <1102480913.1049.24.camel@jzny.localdomain> <41B68E5D.2080009@trash.net>
	 <1102509111.1051.54.camel@jzny.localdomain>
	 <20041208143212.GL1371@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Andrew Morton <akpm@osdl.org>,
        Thomas Cataldo <tomc@compaqnet.fr>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041208143212.GL1371@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-08 at 09:32, Thomas Graf wrote:

> I've put together a small testsuite allowing to easly run tests for
> multiple versions of iproute2. It can be found at:
> 	http://people.suug.ch/~tgr/iproute2/tc-testsuite.tar.gz
> 

Good stuff. Hopefully we can run these tests everytime we make changes
going forward. We cant compromise quality by handwaving on instinct.
Famous last words: "that couldnt have possibly caused a bug down there".
I will take a look at what you have and integrate my 20-30 testcases if
they are not covered over time - or may be adpat what you have to follow
how i do things or maybe i can send them to you and you can integrate
them.

> iproute-2.6.9 was sucessful with all kernels. I couldn't test with the
> old 2.4.7 iproute2 yet since the syntax has changed and I need to adopt
> the tests first. I will create better tests and run it on patrick's
> patch when I get home.

That would be appreaciated. 

cheers,
jamal
