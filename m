From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] s390: claw network device driver
Date: Tue, 29 Mar 2005 08:48:07 +0100
Message-ID: <OF6B8E4881.48C8D8FB-ON41256FD3.0029171C-41256FD3.002ADBAE@de.ibm.com>
References: <20050329071002.GA16204@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, Frank Pavlic <PAVLIC@de.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20050329071002.GA16204@havoc.gtf.org>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

> > Was cc'ed to linux-net last Thursday, but it looks like the messages was
> > too large and the vger server munched it.
>
> As mentioned in the email, you want netdev, not linux-net...

we are currently thinking about changing the sign-off chain for the s390
network patches. Dave suggested that they should go through your hands.
If that is ok with you the new sign-off chain would be Frank Pavlic,
Jeff Garzik, Bitkeeper. This would solve two problems:
1) Frank would create the patches and since he knows much more about
   linux networking then I do, hopefully the patches and the descriptions
   will improve (and you can probably teach him to send the patches to
   netdev instead of linux-net).
2) The patches won't just slip in anymore but get a real review.

blue skies,
   Martin

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH
