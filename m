From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [patch] (2/8) Add 802.3ad support to bonding (released
 to bonding on sourceforge)
Date: Thu, 20 Mar 2003 16:43:52 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF1BD71312.6E4C42DC-ON88256CF0.000314A8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: hshmulik@intel.com, bonding-devel@lists.sourceforge.net,
   bonding-announce@lists.sourceforge.net, linux-net@vger.kernel.org,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org









>So when do these changes end up being sent to myself or
>Jeff for mainline inclusion?
>
>I have no objection to the sourceforge project for bonding, but
>I do object to there being such latency between what the sourceforge
>tree has (especially bug fixes) and what gets submitted into the
>mainline.
>
>Personally, I'd prefer that all development occur in the mainline
>tree.  That gives you testing coverage that is impossible otherwise.

      Fair enough; the delay has gotten excessive of late.

      Would it be satisfactory going forward for the sourceforge site to
contain patches to "standard" releases (e.g., 2.4.20), and do updates to
the current development kernel and the sourceforge site simultaneously? In
other words, sourceforge has a patch containing all bonding updates since
2.4.20 (or whichever version) was released, and each time that patch is
updated, the incremental update goes out for inclusion in the development
kernel.

      -J
