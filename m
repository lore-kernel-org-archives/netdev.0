From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: 19 Jan 2005 23:47:30 -0500
Message-ID: <1106196449.1042.46.camel@jzny.localdomain>
References: <OF0E859D23.C429AEE7-ON41256F8E.006F7D15-41256F8E.00765607@de.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Christian =?ISO-8859-1?Q?Borntr=E4ger?= <christian@borntraeger.net>,
        "David S. Miller" <davem@davemloft.net>,
        Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com, waldi@debian.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Frank Pavlic <PAVLIC@de.ibm.com>
In-Reply-To: <OF0E859D23.C429AEE7-ON41256F8E.006F7D15-41256F8E.00765607@de.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-19 at 16:32, Frank Pavlic wrote:

> Mit  freundlichen Gr=FCssen / Best regards
> Frank Pavlic

Ok, thanks to both you and Christian for the explanations.
I think i understand better now. So essentially the hypervisor
assumes the OSInstance speaks L3 (but not exactly L2);->
Yep, that would be a little challenging .. I have other suggestions
on resolving some of this but i sympathize with the process you have to
go through so i wont burden you with it;-> I think the patch that was in
is good nuf a solution.

BTW, How did this work out in other OSes you mentioned?
For something as expensive as these beasts i have heard are, I
have to say i am a little suprised by this "deficiency".

cheers,
jamal
