From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Thu, 22 Aug 2002 15:34:55 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <OFB94D6180.E856067C-ONC1256C1D.004A69B6@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, owner-netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

      kuznet@ms2.inr.ac.ru
      08/21/02 07:13 PM


  > Hello!

  > > What about implementing your alternative proposal in 2.5 and to use
  > > the current approach in a next 2.4.x kernel?

  > I do not see any good reasons to do this differently.

  > Alexey


      "David S. Miller" <davem@redhat.com>
      08/21/02 11:55 PM


  >    From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
  >    Date: Wed, 21 Aug 2002 19:00:39 +0200

  >      > In this way we are guaranteed not to have problems of this kind
  >      > in future.

  >    What about implementing your alternative proposal in 2.5 and to use
  >    the current approach in a next 2.4.x kernel?

  > Just because you have some code depending upon this doesn't
  > mean that is the way we should implement it in 2.4.x

  > We should do it right from the start.  Because doing it properly
  > hurts no other driver except for yours. :-)


Well, I tried it;-)
Sometimes programmers are as lazy as something.

But in fact, I'm on your side.

So it's time for another patch. However, I cannot foresee when I
finish this work.


Regards,

Andreas

--
Linux for eServer Development
Tel :  +49-7031-16-4640
Notes mail :  Andreas Herrmann/GERMANY/IBM@IBMDE
email :  aherrman@de.ibm.com
