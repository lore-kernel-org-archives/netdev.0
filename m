From: "David S. Miller" <davem@davemloft.net>
Subject: Re: generic 802.11 stack
Date: Wed, 15 Sep 2004 10:06:11 -0700
Sender: acx100-devel-admin@lists.sourceforge.net
Message-ID: <20040915100611.4d66a952.davem@davemloft.net>
References: <4145352F.4040807@pobox.com>
	<41485608.3040509@atheros.com>
	<20040915085526.2c0d2904.davem@davemloft.net>
	<200409150948.58583.sam@errno.com>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: greg@atheros.com, vkondra@mail.ru, mcgrof@studorgs.rutgers.edu,
 acx100-devel@lists.sourceforge.net, hadi@cyberus.ca, jgarzik@pobox.com,
 netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: Sam Leffler <sam@errno.com>
In-Reply-To: <200409150948.58583.sam@errno.com>
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 09:48:57 -0700
Sam Leffler <sam@errno.com> wrote:

> On Wednesday 15 September 2004 08:55 am, David S. Miller wrote:
> > On Wed, 15 Sep 2004 07:47:36 -0700
> >
> > greg chesson <greg@atheros.com> wrote:
> > > Vladimir Kondratiev wrote:
> > > > Let me answer to the set of questions raised:
> > > >
> > > > - dual licensing: I am not ready to answer for legal. I will discuss
> > > > with proper people and answer.
> > >
> > > end the end it is your choice.
> >
> > He has to also ask the person who wrote the code he is
> > basing his work upon, and that would be me :-)
> 
> That assumes he uses no code from somewhere else.

Not at all.  If he wants to change the licensing of any
piece of code, he has to get permission from all the authors.

So, firstly, if he wants to take my code and extend it in any
way he'll need permission from me to use it as anything other
than pure GPL.

Secondly, if he wants to add BSD code to it he cannot do so
without working out the previous paragraph.


-------------------------------------------------------
This SF.Net email is sponsored by: thawte's Crypto Challenge Vl
Crack the code and win a Sony DCRHC40 MiniDV Digital Handycam
Camcorder. More prizes in the weekly Lunch Hour Challenge.
Sign up NOW http://ad.doubleclick.net/clk;10740251;10262165;m
