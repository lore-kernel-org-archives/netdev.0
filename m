From: Nils Holland <nholland@tisys.org>
Subject: Re: [bisected] tg3 broken in 3.18.0?
Date: Tue, 16 Dec 2014 21:38:15 +0100
Message-ID: <20141216203815.GA6022@teela.fritz.box>
References: <20141213210251.GA12812@teela.fritz.box>
 <548EF90A.5070607@gmail.com>
 <CAA93t1qyZE-9tw8pg1KG6g4iyy0QMW=iass5w=6ZGMTMu+vi_A@mail.gmail.com>
 <54907324.4040102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rajatxjain@gmail.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54907324.4040102@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 16, 2014 at 04:00:04PM -0200, Marcelo Ricardo Leitner wrote:
> On 16-12-2014 14:04, Rajat Jain wrote:
> > Hello All,
> >
> > Apologies for jumping in late, but for some reason I do not see the
> > original mail in my inbox. However I am taking a look at the mails as
> > sent on linux-pci (and I will keep an eye out for the bug report that
> > Bjorn asked for).
> >
> 
> np!
> Nils would you create that BZ please? As you did all the bisect.. :)

I'm only just catching up with all the new messages in this thread,
but I've already opened a bug report, as requested. Come and find it
at:

https://bugzilla.kernel.org/show_bug.cgi?id=89821

Feel free to add more relevant details to it! :-)

Greetings,
Nils
