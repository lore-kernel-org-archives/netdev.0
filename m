From: jamal <hadi@cyberus.ca>
Subject: Re: Resend WAS(Re: cls patchlet
Date: 03 Oct 2004 18:22:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096842156.1047.357.camel@jzny.localdomain>
References: <1096833127.1048.333.camel@jzny.localdomain>
	 <1096834352.1046.349.camel@jzny.localdomain>
	 <20041003151216.5a56531f.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041003151216.5a56531f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sun, 2004-10-03 at 18:12, David S. Miller wrote:
> On 03 Oct 2004 16:12:32 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > Ignore previous. This is better formated ;->
> 
> Any particular reason not to remove this work into the
> common code in tcf_action_exec()?  Like so:

Looks good ;-> Go ahead and push that instead and i will run my
regression tests on your changes.

cheers,
jamal
