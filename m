From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]: Adjust qlen when grafting in multiple qdiscs
Date: 17 Nov 2003 14:25:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1069097101.1022.117.camel@jzny.localdomain>
References: <3FB3996A.6080008@trash.net>
	 <1069076786.1075.19.camel@jzny.localdomain>  <3FB8DDE0.1070105@trash.net>
	 <1069081153.1022.20.camel@jzny.localdomain>  <3FB8F3BF.6050509@trash.net>
	 <1069090210.1022.64.camel@jzny.localdomain>  <3FB9103C.9080504@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FB9103C.9080504@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-11-17 at 13:15, Patrick McHardy wrote:

> >My opinion is that since these interfaces (ex qdisc) exist they
> >exist to be (ab)used. 
> >Dsmark happens to work well with the single queue - maybe thats what
> >needs to be documented as opposed to saying it deviates from a purist
> >angle.
> >  
> >
> As I said I've never used dsmark, I changed it while fixing TBF (where
> it is a problem, TBF was changed not long ago to support attaching inner
> qdiscs), so anything is fine with me. I just became a purist defending
> correctness of the patch ;)

Now that we have invoked Werner - lets wait for his response then ;->
Sorry, didnt meant to drag this into 5-6 emails thread.
I closely looked at your other changes on that patch and they looked
fine.

cheers,
jamal
