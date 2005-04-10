From: jamal <hadi@cyberus.ca>
Subject: Re: [Fwd: Re: connector is missing in 2.6.12-rc2-mm1]
Date: 10 Apr 2005 11:08:21 -0400
Message-ID: <1113145700.1088.324.camel@jzny.localdomain>
References: <Xine.LNX.4.44.0504101055470.8507-100000@thoron.boston.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Thomas Graf <tgraf@suug.ch>,
        Kay Sievers <kay.sievers@vrfy.org>,
        Herbert Xu <herbert@gondor.apana.org.au>, ijc@hellion.org.uk,
        guillaume.thouvenin@bull.net, greg@kroah.com,
        linux-kernel@vger.kernel.org, akpm@osdl.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0504101055470.8507-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-10 at 10:56, James Morris wrote:
> On 10 Apr 2005, jamal wrote:
> 
> > Thats what the original motivation for konnector was. To make it easy
> > for joe dumbass.
> 
> Who you really want writing kernel code :-)

Ok, let me take that back then ;->
The value is in allowing people who are kernel hackers that are trying
to focus on an entirely different problem to not really know much about
the internals of the messaging subsystem (if you wanna call netlink
that). A good example will be the fork patches which were posted
recently.

cheers,
jamal
